module Brightpearl
  class ProductService
    class Product < Brightpearl::ProductService


      def productName
        salesChannels.first.productName
      end
      
      def productGroupId
        attributes[:productGroupId] ? attributes[:productGroupId] : 0
      end
      
      def sku
        identity.sku
      end
      
      def groupSku
        sku[0..-4]
      end
      
      def price
        raise RuntimeError, "Price attribute is missing for Brightpearl product #{self.id}" if attributes[:price].blank?
        (attributes[:price] && attributes[:price].to_f > 0) ? attributes[:price].to_f : 99999
      end
      
      def warehouse_on_hand(warehouse_id)
        if self.availability && self.availability['warehouses'][warehouse_id.to_s]
          return self.availability['warehouses'][warehouse_id.to_s]['onHand']
        else
          return 0
        end
      end
      
      def custom_field(name)
        (attributes[:customFields] && attributes[:customFields].attributes.key?(name)) ? attributes[:customFields].attributes[name] : nil 
      end

      def self.all 
        self.all_ranged #(:params=>{:includeOption=>'customFields'})
      end
      
      
      def self.all_full_data
        products=self.all_ranged(:params=>{:includeOptional=>'customFields'}) 
        product_prices=ProductPrice.all_ranged
        priceMap = product_prices.map {|p| [p.productId, p] }
        availabilities={}
        begin 
          (0..((products.last.id-1000)/200)).each do |offset|
            availabilities.merge! ::Brightpearl::WarehouseService::ProductAvailability.get("#{1000+(offset*200)}-#{1000+200+(offset*200)}")
          end
        rescue Brightpearl::BadRequest => e 
          logger.info "End of Availability Hack"
          logger.info e
        end
        
        products.each do |p|
          p.price=nil

          begin  
            if price=(priceMap.assoc(p.id) ? priceMap.assoc(p.id)[1] : nil)
              #puts price.to_s 
              retail=price.priceLists.select {|pl| pl.priceListId==2 }
              p.price=retail[0] ? retail[0].quantityPrice.attributes['1'] : nil 
              
              sale1=price.priceLists.select {|pl| pl.priceListId==3 }
              sale2=price.priceLists.select {|pl| pl.priceListId==4 }
              sale3=price.priceLists.select {|pl| pl.priceListId==5 }
              
              case 
              when sale3.any? && sale3.first.quantityPrice.attributes["1"] #had to add this because some items were sending empty pricelists and others weren't 
                sale=sale3
              when sale2.any? && sale2.first.quantityPrice.attributes["1"]
                sale=sale2
              else
                sale=sale1
              end
              
              p.sale_price=sale[0] ? sale[0].quantityPrice.attributes['1'] : nil 
            else
              puts "No price found for #{p.inspect}"
            end
          rescue 
            puts $!
            puts "PRICE ERROR"
            puts p.inspect
            puts price.inspect if price
          end
          
          p.in_stock=nil 
          p.on_hand=nil 
          p.allocated=nil 
          p.availability=availabilities[p.id.to_s]
          
          begin 
            if p.availability
              total=p.availability["total"]
              p.in_stock=total["inStock"]
              p.on_hand=total["onHand"]
              p.allocated=total["allocated"]
            else
              puts "No availability found for #{p.inspect}"
            end 
          
          rescue 
            puts $!
            puts "AVAILABILITY ERROR"
            puts p.inspect
            puts availability.inspect if availability         
          
          end
        
        end
        products 
      end
    end
  end
end