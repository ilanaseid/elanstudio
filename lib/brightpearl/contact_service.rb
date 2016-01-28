module Brightpearl
  class ContactService < Brightpearl::Base
    extend ActiveSupport::Autoload
    
    autoload :Contact
    autoload :PostalAddress
    
    self.service_name='contact'
    self.include_root_in_json=false
  end
end