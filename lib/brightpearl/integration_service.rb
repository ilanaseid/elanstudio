module Brightpearl
  class IntegrationService < Brightpearl::Base
    extend ActiveSupport::Autoload
    
    autoload :Webhook
    
    self.service_name='integration'
    self.include_root_in_json=false
  end
end