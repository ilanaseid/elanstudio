class ApartmentMailer < ActionMailer::Base
  #default from: "from@example.com"
  layout 'mailer'
  default from: "ilana@elanstudio.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.support_request_mailer.notify_hello.subject
  #
  def email_apartment(apartment_visit)
    @subject = "Apartment Visit Request: #{apartment_visit.name}"
    @body = [apartment_visit.name,apartment_visit.email,apartment_visit.what_time, apartment_visit.note].join("\n")
    # desk.com custom header reference here: https://support.desk.com/customer/portal/articles/6728
    headers["x-desk-customer-email"] = apartment_visit.email
    mail to: Settings.contact_info.apartment_visits_email, subject: @subject, reply_to: apartment_visit.email
  end
end
