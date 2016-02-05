class UserMailerPreview < ActionMailer::Preview

  def self.dummy_notifications(amount)
    notifications = []
    amount.times do
      notifications << ProductNotification.new(name: "Test User", email: "test@elanstudio.com", spree_variant_id: [5668, 5528].sample)
    end
    return notifications
  end

  def product_notification
    UserMailer.product_notification("test@elanstudio.com", self.class.dummy_notifications(1))
  end

  def multi_product_notification
    UserMailer.product_notification("test@elanstudio.com", self.class.dummy_notifications(3))
  end

end
