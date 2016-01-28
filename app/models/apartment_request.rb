class ApartmentRequest < ActiveRecord::Base
  after_commit :mailchimp_subscribe

  #attr_accessible :email, :first_name, :last_name, :newsletter, :utm_source, :utm_medium

  validates_presence_of :email
  validates_format_of :email, :with=>/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

private

  def mailchimp_subscribe
    Mailchimp::SubscribeApartment.perform_async(self.id)
  end
end
