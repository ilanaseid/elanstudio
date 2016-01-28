class EmailSubscriber < ActiveRecord::Base
  before_save :normalize_email
  after_create :mailchimp_subscribe

  serialize :interests, JSON

  @@email_format_validation_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validates_format_of :email, :with => @@email_format_validation_regex

  def self.email_valid?(email_address)
    @@email_format_validation_regex.match(email_address) ? true : false
  end

private

  def mailchimp_subscribe
    Mailchimp::SubscribeNewsletter.perform_async(self.email, {'utm_source'=>self.utm_source, 'utm_medium'=>self.utm_medium})
  end

  def normalize_email
    self.email = self.email.strip.downcase
  end

end
