class ApartmentVisit < ActiveRecord::Base
  #attr_accessible :email, :name, :note, :what_time

  validates_presence_of :name, :email, :what_time
  validates_format_of :email, :with=>/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

end
