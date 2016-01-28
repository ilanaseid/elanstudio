module Brightpearl
  class WarehouseService
    class ShippingMethod < Brightpearl::WarehouseService
      
      self.include_root_in_json=false
    end
  end
end


# [#<Brightpearl::WarehouseService::ShippingMethod:0x007fd6b7e0a048
#   @attributes=
#    {"id"=>6,
#     "name"=>"Ground",
#     "code"=>"",
#     "breaks"=>"10,100,250,1000,100000",
#     "methodType"=>1,
#     "additionalInformationRequired"=>false},
#   @persisted=true,
#   @prefix_options={}>,
#  #<Brightpearl::WarehouseService::ShippingMethod:0x007fd6b7e09468
#   @attributes=
#    {"id"=>7,
#     "name"=>"Overnight",
#     "code"=>"O",
#     "breaks"=>"",
#     "methodType"=>1,
#     "additionalInformationRequired"=>false},
#   @persisted=true,
#   @prefix_options={}>,
#  #<Brightpearl::WarehouseService::ShippingMethod:0x007fd6b7e08a18
#   @attributes=
#    {"id"=>8,
#     "name"=>"2nd Day",
#     "code"=>"2D",
#     "breaks"=>"",
#     "methodType"=>1,
#     "additionalInformationRequired"=>false},
#   @persisted=true,
#   @prefix_options={}>]
