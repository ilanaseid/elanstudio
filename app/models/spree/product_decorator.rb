Spree::Product.class_eval do

  validates_uniqueness_of :name #added because Brightpearl forces product name uniqueness to correlate variations, so we should do it here too as a safety check

  delegate_belongs_to :master, :brightpearl_brand_id, :brightpearl_product_group_id, :brightpearl_product_id

  after_commit :link_cms_content

  def cms_product
    ::Product.find_by(spree_product_id: self.id)
  end

  def cms_product_attributes=(attributes={})
    @cms_product_attributes=attributes
  end

  def cms_product_attributes
    @cms_product_attributes || {}
  end

  def total_on_hand
    # total for ALL variants at ALL locations.
    if self.variants_including_master.any? { |v| !v.should_track_inventory? }
      Float::INFINITY
    else
      self.stock_items.to_a.sum(&:count_on_hand) #original spree doesn't have to_a so it was doing the sum in the DB, here we can eager load and do the sum
    end
  end

  def location_total_on_hand(stock_location)
    if self.variants_including_master.any? { |v| !v.should_track_inventory? }
      Float::INFINITY
    else
      self.stock_items.where(stock_location: stock_location).to_a.sum(&:count_on_hand) #original spree doesn't have to_a so it was doing the sum in the DB, here we can eager load and do the sum
    end
  end

  def default_location_total_on_hand
    # total for all variants at default location only
    if self.variants_including_master.any? { |v| !v.should_track_inventory? }
      Float::INFINITY
    else
      self.stock_items.at_default_stock_location.to_a.sum(&:count_on_hand) #original spree doesn't have to_a so it was doing the sum in the DB, here we can eager load and do the sum
    end
  end


  def link_cms_content
    cms_content=::Product.find_or_initialize_by(spree_product_id: self.id)
    cms_content.title=self.name
    cms_content.subtitle=self.name
    cms_content.brand_id=::Brand.find_by(brightpearl_brand_id: self.brightpearl_brand_id).id
    cms_content.brightpearl_sku=self.sku
    cms_content.brightpearl_brand_id=self.brightpearl_brand_id
    cms_content.brightpearl_product_group_id=self.brightpearl_product_group_id

    cms_product_attributes.each do |k,v|
      cms_content.send("#{k}=",v)
    end

    if cms_content.new_record?
      cms_content.basename=self.name.parameterize.underscore
      cms_content.content_blocks.build(type: 'raw')
    end

    #puts cms_content.changes
    cms_content.save! if cms_content.changed?
  end

end
