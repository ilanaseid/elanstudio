module Mailchimp
  class SubscribeApartment
    include Sidekiq::Worker

    def perform(apartment_request_id)

      if Settings.mailchimp.readonly
        logger.info "Mailchimp is readonly"
        return
      end

      apartment_list_id="06f85ee271" #The Line Apartment

      apartment_request=ApartmentRequest.find(apartment_request_id)

      logger.debug "Subscribing #{apartment_request.email} to Mailchimp Apartment list."
      begin
        MAILCHIMP.lists.subscribe(
          {
            :id => apartment_list_id,
            :email => { :email => apartment_request.email },
            :merge_vars => {
              :FNAME => apartment_request.first_name,
              :LNAME => apartment_request.last_name,
              :UTM_SOURCE=>apartment_request.utm_source,
              :UTM_MEDIUM=>apartment_request.utm_medium,
              :groupings => {
                0 => { id: 7341, groups: ["The Apartment – New York", "The Apartment – Los Angeles"]}
              }
            },
            :double_optin => false }
          )
      rescue Gibbon::MailChimpError => e
        case e.code #special method on MailChimpError with result code
          when 214,215,220,232  #232 no record for unsubscribe, #220 email banned, #214 already subscribed
            logger.debug "Rescuing a Mailchimp error and not retrying because it is allowed."
            logger.debug e.message
          else
            raise e
        end
      end

      if apartment_request.newsletter?
        logger.debug "Apartment request includes newsletter signup."
        SubscribeNewsletter.perform_async(apartment_request.email, {'first_name'=>apartment_request.first_name, 'last_name'=>apartment_request.last_name, 'utm_source'=>apartment_request.utm_source, 'utm_medium'=>apartment_request.utm_medium})
      end
    end
  end
end
