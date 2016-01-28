module CMS
  class UpdateOnOrder
    include Sidekiq::Worker

    def perform(order_id)
      order=Spree::Order.find(order_id)
      products=order.products

      products.each do |product|
        cms_product=Product.find_by(spree_product_id: product.id)
        if product.default_location_total_on_hand > 0
          cms_product.touch
        else
          logger.info "Setting system flag to 'Sold Out' for #{product.inspect}"
          cms_product.update_attributes(:system_flag=>'Sold Out')
        end
      end
    end
  end
end
