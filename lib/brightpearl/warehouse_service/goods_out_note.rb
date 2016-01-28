module Brightpearl
  class WarehouseService
    class GoodsOutNote < Brightpearl::WarehouseService
      self.collection_name='order/*/goods-note/goods-out'
      
      self.include_root_in_json=false
    end
  end
end

#/warehouse-service/order/{ID-SET}/goods-note/goods-out/{ID-SET}