require 'base64'

class SystemMailer < ActionMailer::Base
  layout 'mailer'
  default from: "ilana@elanstudio.com"

  def general(to, subject, body, attach=[])
    @body = body

    attach.each do |attachment|
      attachments[attachment[:name]]={ :content => Base64.strict_encode64(attachment[:content]), :encoding => 'base64' }
    end

    mail to: to, subject: subject
  end
end
