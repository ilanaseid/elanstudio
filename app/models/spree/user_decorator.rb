Spree::User.class_eval do
  before_create :opt_into_email
  after_commit  :setup_newsletter_subscriptions, on: :create
  after_update  :update_subscriptions, :update_notifications, if: :email_changed?

  has_many :wishlist_items

  validates_presence_of :firstname, :lastname

  def default_ship_address
    default_ship_address = last_order ? last_order.ship_address.clone : Spree::Address.default
  end

  def default_bill_address
    default_bill_address = last_order ? last_order.bill_address.clone : Spree::Address.default
  end

  def last_credit_card
    #last_credit_card =
  end

  def last_order
    @last_order ||= orders.complete.order('created_at desc').first
  end

  def staff?
    (%w(staff staff_retail staff_customer_service) & spree_roles.map(&:name)).any?
  end

private

  def opt_into_email
    self.newsletter = true
  end

  def setup_newsletter_subscriptions
    Mailchimp::UpdateUserSubscriptions.perform_async(self.id)
  end

  def update_subscriptions
    EmailList.update_subscriptions_address(changes[:email][0], changes[:email][1])
  end

  def update_notifications
    ProductNotification.where(email: changes[:email][0].strip.downcase).update_all(email: changes[:email][1].strip.downcase)
  end

end
