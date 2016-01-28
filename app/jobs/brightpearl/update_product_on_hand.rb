module Brightpearl
  class UpdateProductOnHand
    include Sidekiq::Worker
  
    def perform(brightpearl_product_id)

      #TODO: to reset stock levels, stock items need to be set to 0 first otherwise it's additive/subtractive or :adjust_count_on_hand, :set_count_on_hand
      
      brightpearl_product = ::Brightpearl::ProductService::Product.find(brightpearl_product_id)
      availability = ::Brightpearl::WarehouseService::ProductAvailability.get(brightpearl_product_id)
      
      logger.info "Availability for Brightpearl product_id #{brightpearl_product_id}: #{availability}"
      
      spree_variant=Spree::Variant.find_by_brightpearl_product_id(brightpearl_product_id)
      if spree_variant
        logger.info "WARNING: not performing updates due to BP issues, but would have done the following:"
        logger.info "WARNING: would have changed spree_variant #{spree_variant.inspect} with current total_on_hand #{spree_variant.total_on_hand}"

#        spree_variant.stock_items.each do |stock_item|
#           #stock_item.stock_movements.create(:quantity=>product.on_hand)
#           stock_item.set_count_on_hand(availability['total']['onHand'])
#         end 
#         
#         # Clear cache and turn off system archive flag
#         # Product.where(:spree_product_id=>spree_variant.product_id).update(updated_at: Time.now)
#         cms_product = Product.find_by(spree_product_id: spree_variant.product_id)
#         if cms_product && cms_product.spree_product.total_on_hand > 0
#           cms_product.system_flag=''
#           cms_product.updated_at=Time.now
#           cms_product.save 
#         end
      else
        logger.error "Couldn't find spree variant for #{brightpearl_product_id}"
      end
      

 
    end
  end
end
