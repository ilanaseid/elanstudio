module Mailchimp
  class SubscribeNewsletter
    include Sidekiq::Worker

    def perform(email,options={})
      #logger.debug "Subscribing #{email} with options: #{options.inspect} to Mailchimp Newsletter list."

      if Settings.mailchimp.readonly
        logger.info "Mailchimp is readonly"
        return
      end

      first_name = options['first_name']
      last_name = options['last_name']
      utm_source = options['utm_source']
      utm_medium = options['utm_medium']

      newsletter_list_id="2269eed362" #The Line Newsletter

      logger.debug "Subscribing #{email} with options: #{options.inspect} to Mailchimp Newsletter list."
      begin
        MAILCHIMP.lists.subscribe({:id => newsletter_list_id, :email => {:email => email}, :merge_vars => {:FNAME => first_name, :LNAME => last_name, :UTM_SOURCE => utm_source, :UTM_MEDIUM => utm_medium}, :double_optin => false})
      rescue Gibbon::MailChimpError => e
        case e.code #special method on MailChimpError with result code
          when 214,215,220,232  #232 no record for unsubscribe, #220 email banned, #214 already subscribed
            logger.debug "Rescuing a Mailchimp error and not retrying because it is allowed."
            logger.debug e.message
          when -100
            # Notify Airbrake that we can't subscribe the email address, but don't keep trying the job
            Airbrake.notify(e) if defined?(Airbrake)
            logger.debug "Rescuing an invalid address Mailchimp error and not retrying"
            logger.debug e.message
          else
            raise e
        end
      end
    end
  end
end
