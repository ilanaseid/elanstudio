class SupportRequest < ActiveRecord::Base

  after_create :send_email

  #attr_accessible :comment, :email, :request_type
  validates_presence_of :email, :comment
  validates_format_of :email, :with=>/.+@.+\..+/i

private 

  def send_email
    SupportRequestMailer.email_support(self).deliver
  end
  

end
