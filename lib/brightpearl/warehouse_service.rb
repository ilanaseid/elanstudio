module Brightpearl
  class WarehouseService < Brightpearl::Base
    extend ActiveSupport::Autoload

#     autoload :Product, 'brightpearl/product_service/product'
#     autoload :Brand, 'brightpearl/product_service/brand'
    
    autoload :ProductAvailability
    autoload :Order
    autoload :GoodsOutNote
    autoload :ShippingMethod
    autoload :GoodsInSearch
    autoload :Warehouse
    
    
    self.service_name='warehouse'
    self.include_root_in_json=true
  end
end