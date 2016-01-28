module TriggerEmails
  class ProductNotificationMailer
    include Sidekiq::Worker

    def perform
      # Don't send any notifications if that environment shouldn't.
      if Settings.trigger_emails.disable_product_notification_emails
        logger.info "Product Notification emails have been disabled, not sending."
        return
      end

      batch = self.class.collect_sendable
      # One email of notificatons (value) called for every email address (key)
      batch.each do |email, notifications|
        send_email_transactionally(email, notifications)
      end
    end

    def send_email_transactionally(email, notifications)
      ProductNotification.transaction do
        ProductNotification.where(id: notifications.collect(&:id)).update_all(sent_at: Time.now)
        UserMailer.product_notification(email, drop_duplicates(notifications)).deliver
      end
    end

    def drop_duplicates(notifications)
      notifications.uniq { |notification| notification.spree_variant_id }
    end

    def self.collect_sendable
      ProductNotification.ready_to_send.group_by { |notification| notification.email }
    end

  end
end
