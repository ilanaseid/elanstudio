class EmailInterestGroup < ActiveRecord::Base
  validates_presence_of :email_list
  belongs_to :email_list
  # unfortunately the non-RESTful Mailchimp API 2.0 does not list interest group id in calls to member_info
  # rather you have to map the names of the interests under the umbrella of grouping id
end
