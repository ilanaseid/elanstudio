module Brightpearl
  class OrderService < Brightpearl::Base
    extend ActiveSupport::Autoload
    
    autoload :Order
    autoload :Row
    autoload :OrderSearch
    autoload :Note
    
    self.service_name='order'
    self.include_root_in_json=false
  end
end