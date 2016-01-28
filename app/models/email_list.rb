class EmailList < ActiveRecord::Base
  validates_uniqueness_of :mailchimp_list_id
  default_scope { where(environment: Settings.mailchimp.environment) }
  scope :visible_to_users, -> { where(visible_to_users: true) }
  has_many :email_interest_groups

  # double_optin - optional flag to control whether a double opt-in confirmation message is sent, defaults to true. Abusing this may cause your account to be suspended.
  # update_existing - optional flag to control whether existing subscribers should be updated instead of throwing an error, defaults to false
  # replace_interests - optional flag to determine whether we replace the interest groups with the groups provided or we add the provided groups to the member's interest groups (optional, defaults to true)
  # send_welcome - optional if your double_optin is false and this is true, we will send your lists Welcome Email if this subscribe succeeds - this will *not* fire if we end up updating an existing subscriber. If double_optin is true, this has no effect. defaults to false.

  def subscribe(email)
    MAILCHIMP.lists.subscribe({:id => self.mailchimp_list_id, :email => {:email => email}, :double_optin => false, update_existing: true})
  end

  def unsubscribe(email)
    MAILCHIMP.lists.unsubscribe(:id => self.mailchimp_list_id, :email => {:email => email}, :delete_member => false, :send_notify => false)
  end

  def self.subscribe_multiple(lists, email)
    lists.each do |list|
      list.subscribe(email)
    end
  end

  def self.unsubscribe_multiple(lists, email)
    lists.each do |list|
      list.unsubscribe(email)
    end
  end

  def update_member_email(old_email, new_email)
    begin
      MAILCHIMP.lists.update_member(id: self.mailchimp_list_id, email: {email: old_email}, merge_vars: {email: new_email})
    rescue Gibbon::MailChimpError => e
      logger.info("Mailchimp Error: #{e}. Code: #{e.code}")
      if e.code == 214 # existing subscription with new address
        handle_previous_subscription_conflict(self, old_email, new_email)
      else
        Airbrake.nofity(e)
      end
    end
  end

  def self.update_subscriptions_address(old_email, new_email)
    lists = self.look_up_all_subscriptions(old_email).map {|result| result['id']}
    EmailList.where(mailchimp_list_id: lists).each do |list|
      list.update_member_email(old_email, new_email)
    end
  end

  def handle_previous_subscription_conflict(list, old_email, new_email)
    # error 214 is VERY misleading. Mailchimp will throw 214 if the address was EVER subscribed (EVEN IF they are currently UNSUBSCRIBED).
    # so, instead of simply updating member info, we now have to:
    # 1) unsubscribe old email from the list (like we want)
    # 2) subscribe the 'new' (existing/duplicate) email to this list AGAIN, with 'update_existing: true', so that it overrides ANY previous setting (sub or unsub)
    # because: if we'd just done nothing, assuming the 'existing subscription' error meant that email was literally 'subscribed', it could be wrong sometimes
    logger.info("User is changing address from #{old_email} to #{new_email}, which was already on #{list.mailchimp_name} at some point, and may or may not be currently subscribed. Fixing.")
    list.unsubscribe(old_email)
    list.subscribe(new_email)
  end

  def self.look_up_all_subscriptions(email_address)
    begin
      MAILCHIMP.helper.lists_for_email({email: {email: email_address.strip.downcase }})
    rescue Gibbon::MailChimpError => e
      # don't blow up if email address has no subscriptions
      logger.info("Mailchimp Error: #{e}. Code: #{e.code}")
      if [232, 215].include?(e.code) # new users / old users that unsubbed
        return []
      else
        Airbrake.notify(e)
      end
    end
  end

  def lookup_member_info(email_address)
    MAILCHIMP.lists.member_info({id: self.mailchimp_list_id, emails: [email: email_address]})['data']
  end

  def lookup_groups_for_member(email_address)
    results = lookup_member_info(email_address)
    return [] if results.empty? # no groupings or wrong email
    return [] unless results.first['merges']['GROUPINGS']
    results.first['merges']['GROUPINGS']
  end

  def interest_groupings
    begin
      MAILCHIMP.lists.interest_groupings(id: self.mailchimp_list_id)
    rescue Gibbon::MailChimpError => e
      return [] if e.code == 211 # list has no groupings
    end
  end

  def update_member_group_preferences(groups, email_address)
    groupings_hash = format_groups(groups)

    MAILCHIMP.lists.update_member(
      id: self.mailchimp_list_id,
      email: { "email" => email_address},
      merge_vars:
        { groupings: groupings_hash },
      update_existing: "true",
      double_optin: "false",
      replace_interests: true
      )
  end

  def format_groups(groups)
    # syntax needs to be:
    # {
    #   0 => { :id => 1234, :groups => ['group 1', 'group 2']}
    #   1 => { :id => 4567, :groups => ['group 3']}
    # }
    result = {}
    groupings = groups.group_by do |group|
      group.mailchimp_grouping_id
    end
    groupings.each_with_index do |(key, value), index|
      result[index] = {id: key, groups: value.map(&:mailchimp_name)}
    end
    result
  end

  def self.look_up_visible_subscriptions(email_address)
    # returns array of Ruby email list objects where user is subscribed
    list_results = self.look_up_all_subscriptions(email_address).map {|result| result['id']}
    EmailList.where(mailchimp_list_id: list_results, visible_to_users: true)
  end

  def self.sync_mailchimp_lists_to_database
    # simple helper to pull new Mailchimp Lists into database
    if !ENV['MAILCHIMP_API_KEY']
      logger.info "Syncing MailChimp Lists to database failed because there is no Mailchimp API key stored."
      return false
    else
      MAILCHIMP.lists.list['data'].each do |mailchimp_list|
        database_list = EmailList.find_or_create_by(mailchimp_list_id: mailchimp_list['id'])
        database_list.update!(mailchimp_name: mailchimp_list['name'])
        database_list.update!(display_name: mailchimp_list['name']) if database_list.display_name.nil?
      end
    end
  end

end
