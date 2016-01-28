module ApplicationHelper
#   USER_SECTION=[spree.account_path, spree.orders_path, main_app.wishlist_items_path]
#   STORIES_SECTION=[main_app.shop_index_path, main_app.shop_category_path(:fashion), main_app.shop_category_path(:home), main_app.shop_category_path(:beauty)]

  def current_order_count
    current_order.nil? ? 0 : current_order.item_count
  end

  def sub_tag_page_title(string)
    if string == 'under_100'
        "Under $100"
      else
        string.titleize
      end
  end

  def current_volume
    @current_volume ||= Volume.published.first
  end

  def current_selection_subnav
    @nav_selections ||= Selection.published.without_options.desc(:publish_at).limit(4)
  end

  def current_apartment
    @current_apartment ||= Apartment.published.first
  end

  def current_site_messaging
    @current_site_messaging ||= SiteMessaging.published.first
  end

  def in_volume?(volume_id)
    return true if @volume && @volume.id==volume_id
    return true if @content && @content.volume_id==volume_id
  end

  def show_sale_menu?
    if Product.published.listed.where(:tags=>/^sale$/i).count >= 12
      return true
    else
      return false
    end
  end

  def product_status_span(product)

    product_status=product_status(product)

    if product_status.present?
      label_text = t('product.status_'+product_status)
      return %Q(<span class="item-status label-#{product_status}"><span>#{label_text}</span></span>).html_safe
    else
      return ''
    end

  end

  def cache_buster
    cache_object=OpenStruct.new

    if params[:preview]
      product=ClearCMS::Content.scoped.without_options.desc(:updated_at).first
    else
      product=ClearCMS::Content.published.without_options.desc(:updated_at).first
    end

    cache_object.cache_key="cache_buster-" << Digest::MD5.hexdigest(([product.cache_key]+params.to_a+[session[:per_page]]).join)
  end

  def cache_buster_all
    cache_object=OpenStruct.new
    product=ClearCMS::Content.without_options.desc(:updated_at).first
    cache_object.cache_key="cache_buster-" << Digest::MD5.hexdigest(([product.cache_key]+params.to_a+[session[:per_page]]).join)
  end

  def product_status(product)
    case product.product_state
      when 'Preview'
        return product_status='preview'
      when 'Discontinued'
        return product_status='discontinued'
      when 'Hidden'
        return product_status='hidden'
      when 'External'
        return product_status='external'
    end

    if product_status.nil? && product.product_state=='Current'
      case
        when product.out_of_stock?
          return product_status='out_of_stock'
        when product.on_sale?
          return product_status='on_sale'
        when product.new_product?
          return product_status='new_product'
        when product.exclusive?
          return product_status='exclusive'
      end
    end

    return ''
  end

  def product_state_class(product)
    if product.product_state.nil?
      return ""
    else
      return "state-#{product.product_state.gsub(' ', '_').downcase}"
    end
  end

  def product_status_class(product)
    status = product_status(product)

    if status == ""
      return ""
    else
      return "status-#{status}"
    end
  end

  def formatted_price(price)
    price.kind_of?(String) ? "$#{price}" : number_to_currency(price.ceil, :precision=>0)
  end

  def formatted_shipping_cost(rate)
    if rate.cost==0 && rate.shipping_method_id==6
      ''
    elsif rate.cost==0
      '(free)'
    else
      "($#{rate.cost.to_i})"
    end
  end

  def enable_usersnap?
    (cookies[:usersnap] && Settings.usersnap_api_key) ? true : false
  end

  def strip_custom_markup(html)
    if html.present?
      html.gsub(/<picture>.*?(<img.*?>).*?<\/picture>/im,'\1')
    end
  end

  def per_page_preference_link(paged_contents)
    case session[:per_page]
      when Settings.pagination.per_page_more
        if paged_contents.total_pages > 1
          calculated_page=((paged_contents.offset_value+paged_contents.to_a.size)/Settings.pagination.per_page_less.to_f).ceil
          %Q(#{link_to t('actions.show_less_items'), params.merge(:per_page_preference=>'less', :page=>calculated_page)} #{content_tag(:span, t('actions.show_more_items'))}).html_safe
        end
      else
        if paged_contents.total_pages > 1
          calculated_page=((paged_contents.offset_value+paged_contents.to_a.size)/Settings.pagination.per_page_more.to_f).ceil
          %Q(#{content_tag(:span, t('actions.show_less_items'))} #{link_to t('actions.show_more_items'), params.merge(:per_page_preference=>'more', :page=>calculated_page)}).html_safe
        end
    end
  end

  def ga_per_page_preference_url
    preference = (session[:per_page]==Settings.pagination.per_page_more) ? 'more' : 'less'
    url_for(params.merge(:per_page_preference=>preference,:only_path=>true)).html_safe
  end

  def nav_category_active_link_to(*args, &block)
    # wrapper for active_link_to to highlight nav categories
    if block_given?
      name          = capture(&block)
      options       = args[0] || {}
      html_options  = args[1] || {}
    else
      name          = args[0]
      options       = args[1] || {}
      html_options  = args[2] || {}
    end
    # are we on a pdp / have enabled nav highlighting? if not skip and run normal active_link_to
    if @enable_nav_highlighting_for_product
      if !@primary_category_already_highlighted && name.downcase == @product.primary_category
        # set the primary category link to active if it hasn't been
        @primary_category_already_highlighted = true
        return active_link_to(name, options, html_options.merge({active: true}))
      elsif !@subcategory_already_highlighted && name.gsub(/\s&\s/, ' ') == @product.first_matching_subcategory(options)
        # set the subategory link to active if it hasn't been
        @subcategory_already_highlighted = true
        return active_link_to(name, options, html_options.merge({active: true}))
      end
    end
    active_link_to(name, options, html_options)
  end

  def is_active_nav_category?(category)
    # nav helper to see if categories are active
    if @enable_nav_highlighting_for_product
      # should only run on PDP
      @product.categories.include?(category.to_s.titleize)
    else
      # else just call is_active_link? same way nav always called it
      is_active_link?(main_app.shop_category_path(category))
    end
  end

  def is_active_nav_tag?(tag)
    # nav helper to see if categories are active
    if @enable_nav_highlighting_for_product
      # should only run on PDP
      @product.tags.include?(tag.to_s.titleize)
    else
      # else just call is_active_link? same way nav always called it
      is_active_link?(main_app.shop_tag_path(tag))
    end
  end

  def editorial_flags(editorial_content)
    if editorial_content.categories.present?
      editorial_flags = ["Musings", "People", "Places", "Object History", "Variations"]
      titelized_categories = editorial_content.categories.map { |category| category.titleize }
      if editorial_flags & titelized_categories != []
        categories_to_display = editorial_flags & titelized_categories
        return categories_to_display[0,3].join(", ")
      else
        return ""
      end
    end
  end

  def fonts_loaded?
    begin
      session[:fonts_loaded]
    rescue => e
      Airbrake.notify(e, :error_message=>"Error reading fonts_loaded")
      return true # just give loaded scenario, (regression to browser FOIT is only consequence if assumption wrong)
    end
  end

  def superuser_view_roles
    # user_class looks at all spree roles and resolves to a single string, depending on which 'wins'
    # in the future it would be better to decouple user_class, which is primarily for analytics, from determining permissions/features.
    return ['staff', 'staff_retail', 'staff_customer_service']
  end

  def display_superuser_ui?
    @display_superuser_ui ||= superuser_view_roles.include?(user_class) && !current_spree_user.disable_staff_inventory_ui
  end

end
