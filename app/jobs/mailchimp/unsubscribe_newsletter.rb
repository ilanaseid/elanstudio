module Mailchimp
  class UnsubscribeNewsletter
    include Sidekiq::Worker
  
    def perform(email,first_name=nil, last_name=nil)
      if Settings.mailchimp.readonly
        logger.info "Mailchimp is readonly"
        return  
      end


      newsletter_list_id="d7796b84c3" #Elan Studio Newsletter
      
      logger.debug "Unsubscribing #{email} from Mailchimp Newsletter list."
      begin 
        MAILCHIMP.lists.unsubscribe({:id => newsletter_list_id, :email => {:email => email}, :merge_vars => {:FNAME => first_name, :LNAME => last_name}, :double_optin => false})        
      rescue Gibbon::MailChimpError => e  
        case e.code #special method on MailChimpError with result code
          when 214,215,220,232  #232 no record for unsubscribe, #220 email banned, #214 already subscribed
            logger.debug "Rescuing a Mailchimp error and not retrying because it is allowed."
            logger.debug e.message
          else
            raise e 
        end
      end
    end
  end
end