Spree::StockItem.class_eval do

  after_save :touch_cms_content
  #after_create :set_cms_content

  scope :at_default_stock_location, -> { where(stock_location: Spree::StockLocation.default)}

private

  def touch_cms_content
    #debugger
    if count_on_hand_changed?
      if count_on_hand==0 && variant.product.default_location_total_on_hand==0 #this one and all variants on product at default location sold out
        logger.debug "Setting CMS content to 'Sold Out'"
        system_flag='Sold Out'
      else
        logger.debug "Setting CMS content to not 'Sold Out'"
        system_flag=nil
      end
      variant.product.cms_product.update_attributes(updated_at: Time.now, system_flag: system_flag)
      #variant.product.cms_product.touch
    end
  end

  def set_cms_content
    if count_on_hand==0 && variant.product.default_location_total_on_hand==0 #this one and all variants on product at default location sold out
      logger.debug "Setting CMS content to 'Sold Out'"
      system_flag='Sold Out'
    else
      logger.debug "Setting CMS content to not 'Sold Out'"
      system_flag=nil
    end
    variant.product.cms_product.update_attributes(updated_at: Time.now, system_flag: system_flag)
  end
end
