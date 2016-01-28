class EmailPreference
  # this is a service object to map the complexities of mailchimp lists and interest groups into a more simple "subscribed" vs "not subscribed" model
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :subscribed, :not_subscribed, :potential_groups, :subscribed_groups, :unsubscribed_groups, :email_address

  def initialize(email_address)
    return unless EmailSubscriber.email_valid?(email_address)
    self.subscribed             = []
    self.not_subscribed         = []
    self.potential_groups       = []
    self.subscribed_groups      = []
    self.unsubscribed_groups    = []
    self.email_address          = email_address
    categorize_lists
    categorize_groups
  end

  def update_user_subscriptions(new_subscription_ids, new_group_ids, email_address=self.email_address)
    previous_subscriptions = self.subscribed
    new_subscriptions      = EmailList.where(mailchimp_list_id: new_subscription_ids)
    previous_groups        = self.subscribed_groups.group_by {|group| group.email_list.mailchimp_list_id}
    new_groups             = EmailInterestGroup.where(mailchimp_id: new_group_ids).group_by {|group| group.email_list.mailchimp_list_id}


    # LISTS #
    # if a previous subscription isn't in new subscriptions, unsubscribe it.
    to_unsubscribe = previous_subscriptions.select do |previous_subscription|
      !new_subscriptions.include?(previous_subscription)
    end

    # if a new subscription isn't already in previous, subscribe it
    to_subscribe = new_subscriptions.select do |new_subscription|
      !previous_subscriptions.include?(new_subscription)
    end

    # we now have the lists we need to subscribe and unsubscibe:
    EmailList.subscribe_multiple(to_subscribe, email_address)
    EmailList.unsubscribe_multiple(to_unsubscribe, email_address)

    # GROUPS #
    # groups are an ordeal in Mailchimp API v.2.0, which is not RESTful. :(
    # (basically you can either add a mixture of interest groups, or wholesale replace them all. there's no deleting!
    #  worse, you cannot set it through the user, you have to do it through the list and pass user info)

    # logic:
    # (new groups) minus (old groups not in new groups) = final group preferences
    # everything else is set to blank hash of 0 groups.
    final_groups = {}
    new_groups.each_key { |list| final_groups[list] = [] }
    previous_groups.each_key { |list| final_groups[list] = [] }

    new_groups.each do |list, groups|
      groups.each do |group|
        final_groups[list] << group
      end
    end
    # replace the interests
    final_groups.each do |mailchimp_list_id, groups|
      EmailList.find_by(mailchimp_list_id: mailchimp_list_id).update_member_group_preferences(groups, email_address)
    end
  end

private

  def categorize_lists
    user_subscriptions = EmailList.look_up_visible_subscriptions(self.email_address)
    EmailList.visible_to_users.each do |visible_list|
      user_subscriptions.include?(visible_list) ? self.subscribed << visible_list : self.not_subscribed << visible_list
    end
  end

  def categorize_groups
    bucket_subscribed_list_groups   # if you are subscribed to a list that has groups, sort your potential groups into a bucket
    sort_subscribed_list_groups     # sort those potential groups into subscribed/not subscribed preferences
    sort_unsubscribed_list_groups   # now take all the groups that belong to your unsubscribed lists, and mark as unsubscribed groups
  end

  def bucket_subscribed_list_groups
    self.subscribed.each do |list|
      grouping = list.lookup_groups_for_member(self.email_address)
      self.potential_groups << grouping.first if !grouping.empty?
    end
  end

  def sort_subscribed_list_groups
    self.potential_groups.each do |grouping|
      grouping['groups'].each do |group|
        category = group['interested'] == true ? self.subscribed_groups : self.unsubscribed_groups
        category << EmailInterestGroup.find_by(mailchimp_grouping_id: grouping['id'], mailchimp_name: group['name'])
      end
    end
  end

  def sort_unsubscribed_list_groups
    self.not_subscribed.each do |list|
       self.unsubscribed_groups += list.email_interest_groups
    end
  end

end
