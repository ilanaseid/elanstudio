object @order
attributes :id, :total, :adjustment_total, :item_total

node(:error, :if=>lambda{ |o| flash[:error].present? }) do
  flash[:error]
end

child :line_items=>:line_items do
  attributes :id, :quantity, :price, :total, :updated_at, :created_at

  child :variant do |variant|
    attributes :id, :name, :options_label, :shipping_category_id, :low_inventory_message

    node :option_label_override do |line_item|
      @cms_product.option_label_override
    end

    @cms_product=variant.product.cms_product
    node :brand_name do
      @cms_product.brand.title
    end

    node :brand_path do
      main_app.brand_path(@cms_product.brand.basename)
    end

    node :default_image do
      @cms_product.default_image_url(:thumb)
    end

    node :product_path do
      main_app.shop_product_path(@cms_product.basename)
    end

    node :final_sale do
     @cms_product.final_sale
    end

  end
end
