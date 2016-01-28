module Brightpearl
  class WarehouseService
    class Order < Brightpearl::WarehouseService
      
      self.include_root_in_json=false
    end
  end
end