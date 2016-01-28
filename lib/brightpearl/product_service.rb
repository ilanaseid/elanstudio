module Brightpearl
  class ProductService < Brightpearl::Base
    extend ActiveSupport::Autoload
    
    autoload :Brand
    autoload :BrightpearlCategory
    autoload :OptionValue
    autoload :Option
    autoload :PriceList
    autoload :ProductList
    autoload :ProductPrice
    autoload :ProductType
    autoload :Product    
    
    self.service_name='product'
  end
end