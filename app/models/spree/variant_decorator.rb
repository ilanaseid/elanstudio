Spree::Variant.class_eval do
  has_many :product_notifications, foreign_key: "spree_variant_id"

  validates_uniqueness_of :sku
  validates_uniqueness_of :brightpearl_product_id, :scope=>:is_master
  validates_presence_of :brightpearl_product_group_id
  validates_presence_of :brightpearl_brand_id
  belongs_to :shipping_category

  delegate :cms_product, to: :product

  def options_label
    label=''
    option_values.each {|o| label << o.presentation}
    label
  end

  def default_location_count_on_hand
    return Float::INFINITY unless self.should_track_inventory?
    self.stock_items.at_default_stock_location.to_a.sum(&:count_on_hand)
  end

  def count_on_hand_at_location(location)
    return Float::INFINITY unless self.should_track_inventory?
    self.stock_items.where(stock_location: location).to_a.sum(&:count_on_hand)
  end

  def low_inventory_message
    inventory_remaining = self.default_location_count_on_hand
    if inventory_remaining.between?(1,3)
      return I18n.t('product.low_inventory_count', remaining: inventory_remaining.to_words).downcase
    else
      nil
    end
  end

  def options_text
    #TODO: hack. remove this patch once we build PDP to support multiple option values/types
    # this just expects we have either 'size' or 'color'
    if product.cms_product.option_label_override == 'Color'
      return "Color: #{self.option_values.first.presentation}"
    end

    values = self.option_values.sort do |a, b|
      a.option_type.position <=> b.option_type.position
    end

    values.to_a.map! do |ov|
      "#{ov.option_type.presentation}: #{ov.presentation}"
    end

    values.to_sentence({ words_connector: ", ", two_words_connector: ", " })
  end

end
