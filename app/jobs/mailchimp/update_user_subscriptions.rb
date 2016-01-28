module Mailchimp
  class UpdateUserSubscriptions
    include Sidekiq::Worker

    def perform(user_id)
      if Settings.mailchimp.readonly
        logger.info "Mailchimp is readonly"
        return
      end

      user=Spree::User.find(user_id)
      if user.newsletter?
        logger.debug "Subscribing #{user.id} #{user.email} to Line and Apartment Newsletters via SubscribeNewsletter job."
        SubscribeNewsletter.perform_async(user.email, {'first_name'=>user.firstname, 'last_name'=>user.lastname, 'utm_source'=>user.utm_source, 'utm_medium'=>user.utm_medium})
        ApartmentRequest.create(email: user.email, first_name: user.firstname, last_name: user.lastname, utm_medium: user.utm_medium, utm_source: user.utm_source)
      else
        logger.debug "Unsubscribing #{user.id} #{user.email} from Newsletter via UnsubscribeNewsletter job."
        UnsubscribeNewsletter.perform_async(user.email, user.firstname, user.lastname)
      end
    end
  end
end

