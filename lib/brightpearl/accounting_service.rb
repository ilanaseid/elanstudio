module Brightpearl
  class AccountingService < Brightpearl::Base
    extend ActiveSupport::Autoload
    
    autoload :TaxCode 
    
    self.service_name='accounting'
  end
end