class SupportRequestMailer < ActionMailer::Base
  default from: "systems@theline.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.support_request_mailer.notify_hello.subject
  #
  def email_support(support_request)
    @subject = "New support request: #{support_request.request_type}"
    @body = "#{support_request.comment}\n\nFrom: #{support_request.email}"
    # desk.com custom header reference here: https://support.desk.com/customer/portal/articles/6728
    headers["x-desk-customer-email"] = support_request.email
    mail to: Settings.contact_info.service_email, subject: @subject, reply_to: support_request.email
  end
end
