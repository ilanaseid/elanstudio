class Product < ClearCMS::Content
  before_save :check_product_state
  before_save :set_available_date
  before_save :set_sort_weight
  before_save :set_searchable


  NEW_PRODUCT_TIMEFRAME=2.weeks

  form_field :spree_product_id, :type=>Integer, :formtastic_options=>{:as=>:select, :collection=>Spree::Product.all}
  form_field :brand_id, :formtastic_options=>{:collection=>Brand.all }
  
  # keep these two just for legacy access
  field :flag

  form_field :system_flag,  :formtastic_options=>{:input_html=>{:disabled=>'true'}}

  form_field :product_state, :formtastic_options=>{:collection=>['Current','Preview','External','Discontinued','Hidden'], :include_blank=>false}

  form_field :available_date, :type=>DateTime, :formtastic_options=>{:input_html=>{:class=>'datetimepicker'}}

  form_field :exclusive, :type=>Boolean
  form_field :final_sale, :type=>Boolean, :formtastic_options=>{:input_html=>{:disabled=>'true'}}

  form_field :original_price, :type=>Float

  form_field :photo_template, :formtastic_options=>{:collection=>['A','B','C']}

  form_field :external_price
  form_field :external_partner
  form_field :external_url, :formtastic_options=>{:input_html=>{:type=>'url'}}

  field :option_label_override  #TODO: Hack. Migrate to proper switching of option_type and option_value on PDP instead of using 'size' and overriding the label for 'size'.

  index({site_id: 1, _type: 1})

  def cache_key #added this to automatically change caches for new items that expire without needed to setup some strange cache clearing mechanism
    "#{super}#{new_product? ? '-new' : ''}"
  end

  self.linked_content_filter={:types=>'Product'}
  belongs_to :brand

  scope :internal, -> { where(:product_state.ne => 'External', :external_url.in => ['', nil]) }
  scope :listed, ->{ weighted.where(:product_state.in=>['Preview', 'Current', 'External']).where(:system_flag.ne=>'Sold Out') }
  scope :not_archived, ->{ weighted.where(:product_state.in=>['Preview', 'Current', 'External'])}
  scope :recently_available, ->{where(:available_date.gt=>Time.now-NEW_PRODUCT_TIMEFRAME).where(:product_state.ne=>'Preview').desc(:available_date)}
  scope :visible, ->{where(:product_state.ne=>'Hidden')}
  scope :weighted, ->{reorder.asc(:sort_weight).desc(:publish_at)}

  def paired_products(count)
    site.contents.published.where(_type: 'Product').limit(count)
  end

  def related_stories(count)
    stories=self.site.contents.published.where(:_type.in=>['Chapter','Footnote']).where(:'linked_contents.linked_content_id'=>self.id.to_s).without_options.desc(:publish_at).limit(count)
  end

  def in_category?(category)
    categories.any?{ |s| s.casecmp(category) == 0 }
  end

  def special_delivery
    raise RuntimeError, "Special delivery is no longer tracked in the CMS."
  end

  def special_delivery=(option)
    logger.debug "DEPRECATED: Special delivery is no longer tracked in the CMS."
  end

  def brand
    Product.get_brand_from_map(self[:brand_id]) || Product.store_brand_in_map(Brand.find(self[:brand_id]))
  end

  def self.get_brand_from_map(id)
    map = RequestStore.store[:brands] ||= {}
    map[id.to_s]
  end

  def self.store_brand_in_map(brand)
    map = RequestStore.store[:brands] ||= {}
    map[brand.id.to_s] = brand
  end

  def self.preload_brands(criteria)
    case
    when criteria.is_a?(Array)
      ids=criteria.collect(&:brand_id).uniq
    when criteria.is_a?(Mongoid::Criteria)
      ids=criteria.pluck(:brand_id).uniq
    end
    if ids.any?
      brands = Brand.where(:id.in=>ids)
      brands.each {|b| store_brand_in_map(b) }
    end
    criteria
  end

  def primary_category
    categories.each do |c|
      case c
        when /fashion/i
          return 'fashion'
        when /beauty/i
          return 'beauty'
        when /home/i
          return 'home'
        when /art/i
          return 'art'
      end
    end
    return 'primary_category_missing'
  end

  def first_subcategory
    categories.each do |category|
      return category unless /fashion|beauty|home/i.match(category)
    end
  end

  def first_matching_subcategory(path)
    # for 'accessories' edge case, make sure we are highlighting the right subcategory.
    # ie, know the difference between highlighting fashion > accessories vs. home > accessories
    match = /^\/shop\/(.*)\//i.match(path)
    if match && categories.exclude?(match[1].titleize)
      return false
    else
      first_subcategory
    end
  end

  def spree_product
     Product.get_spree_product_from_map(self[:spree_product_id]) || Product.store_spree_product_in_map(Spree::Product.includes(:master=>[:default_price,:stock_items],:variants_including_master=>[],:stock_items=>[],:variants=>[:stock_items,:option_values]).find(self[:spree_product_id]))
  end

  def self.get_spree_product_from_map(id)
    map = RequestStore.store[:spree_products] ||= {}
    map[id]
  end

  def self.store_spree_product_in_map(product)
    map = RequestStore.store[:spree_products] ||= {}
    map[product.id]=product
  end

  def self.preload_spree_products(criteria)
    case
    when criteria.is_a?(Array)
      ids=criteria.collect(&:spree_product_id).uniq
    when criteria.is_a?(Mongoid::Criteria)
      ids=criteria.pluck(:spree_product_id).uniq
    end
    if ids.any?
      spree_products = Spree::Product.includes(:master=>[:default_price,:stock_items],:variants_including_master=>[],:stock_items=>[],:variants=>[:stock_items,:option_values]).where(id: ids)
      spree_products.each {|p| store_spree_product_in_map(p) }
    end
    criteria
  end

  def price
    external? ? external_price : spree_product.price
  end

  # TODO: make this inspect and output one of the 4 spree shipping categories
  def shipping_category
    return 'ground'
  end

  def notifiable?
    !discontinued? && !external? && (out_of_stock? || any_out_of_stock? || coming_soon?)
  end

  def wishlistable?
    !(discontinued? || external?)
  end

  def any_out_of_stock?
    return false if external?
    stock_levels=spree_product.variants.collect {|v| v.default_location_count_on_hand }
    stock_levels.include?(0)
  end

  def out_of_stock?
    !external? && spree_product.default_location_total_on_hand <= 0
  end

  def coming_soon?
    product_state=='Preview'
  end

  def current?
    product_state=='Current'
  end

  def discontinued?
    %w(Discontinued Hidden).include?(product_state)
  end

  alias archived? discontinued?

  def external?
    external_url.present? || product_state=='External'
  end

  def new_product?
    available_date.present? && (available_date > (Time.now - NEW_PRODUCT_TIMEFRAME))
  end

  def available?
    product_state=='Current' && spree_product.default_location_total_on_hand > 0
  end

  def available_any_location?
    if !self.spree_product_id.nil?
      spree_product.total_on_hand > 0
    elsif
      # patch for discontinued items without spree product ids
      false
    end
  end

  def on_sale?
    original_price.present? && original_price!=price
  end


  def related(limit=25,type: self._type)
    begin
      result = Sunspot.more_like_this(self) do
        fields :content,:tags,:categories
        paginate per_page: limit
        with :site_id, self.site.id
        with :status, 'PUBLISHED'
        with :sort_weight, 1  #using sort weight here so that it doesn't include sold out, discontinued, or onsale with 1 being the equivalent of available
        with :_type, type
        with(:publish_at).less_than Time.now
      end
      return result.results
    rescue => e
      Airbrake.notify(e) if defined?(Airbrake)
      return []
    end
  end

  def related_selections(count=1)
    self.site.contents.published.where(:'linked_contents.linked_content_id'.in=>[self._id.to_s]).where(:_type=>'Selection').not.lt(end_time: Time.now).desc(:publish_at).limit(count)
  end

  def self.half_or_more_in_stock?(products)
    half = (products.length / 2).round
    sold_out, in_stock = 0, 0
    products.each do |product|
      if product.system_flag == 'Sold Out' || ['Discontinued', 'Hidden'].include?(product.product_state)
        sold_out += 1
      else
        in_stock += 1
      end
      break if in_stock >= half || sold_out > half
    end
    in_stock > sold_out ? true : false
  end

  def self.sort_by_available(products)
    out_of_stock_flags = ['Sold Out', 'Archived', 'Discontinued', 'Hidden']
    in_stock     = []
    out_of_stock = []
    products.each do |product|
      out_of_stock_flags.include?(product.product_state) || out_of_stock_flags.include?(product.system_flag) ? out_of_stock << product : in_stock << product
    end

    in_stock + out_of_stock
  end

  def self.sort_by_weight(products)
    products.sort_by(&:sort_weight)
  end

  def self.all_archived?(products)
    products.each do |product|
      return false if !['Hidden', 'Discontinued'].include?(product.product_state)
    end
    return true
  end

private

  def check_product_state
    self.product_state='Current' if self.product_state.blank?
  end

  def set_available_date
    if (product_state=='Current' || product_state=='External') && state=='Finished'
      self[:available_date]=Time.now if self[:available_date].blank?
    end
  end

  def set_searchable
    if self.product_state=='Hidden'
      self.searchable=false
    else
      self.searchable=true
    end
    return true
  end

  def set_sort_weight
    self.sort_weight=1
    self.sort_weight+=2 if self.on_sale?
    self.sort_weight+=3 if self.system_flag=='Sold Out'
    self.sort_weight+=5 if self.product_state=='Discontinued'
    self.sort_weight+=8 if self.product_state=='Hidden'
  end

end
