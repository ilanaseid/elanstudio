class ShopController < ApplicationController

  include ApplicationHelper
  # include CacheDigests::FragmentHelper # as of Rails 4 cache digests are now part of rails core, TODO: https://www.pivotaltracker.com/story/show/98029344

  before_filter :record_shopping_view, :only => [:category]

  def category
    # TODO: Clean up workaround for forcing 'All' instead of regexes '.*', '.*'
    category_array=(params[:sub_category].present? ? [/^#{params[:category]}$/i, /^#{params[:sub_category]}$/i] : [/^#{params[:category]}$/i])
    featured_products=current_site.contents.published.where(:categories.all=>category_array).and(:_type=>'ProductCategory').with_size(categories: (params[:sub_category].present? ? 2 : 1)).first

    removed_ids = featured_products ? featured_products.linked_contents.collect {|lc| lc.linked_content_id } : []
    @product_category=featured_products unless params[:page] && params[:page].to_i > 1
    @products=products.published.not_archived.where(:categories=>category_regex).and(:categories=>sub_category_regex).and(:id.nin=>removed_ids).page(params[:page]).per(per_page_preference)
  end

  def tag
    featured_products = current_site.contents.published.where(:tags => /^#{params[:tag]}$/i).and(:_type => 'ProductTag').first
    removed_ids = featured_products ? featured_products.linked_contents.collect {|lc| lc.linked_content_id } : []
    @product_tag = featured_products unless params[:page] && params[:page].to_i > 1
    @products = products.published.not_archived.where(:tags=>tag_regex).and(:tags=>sub_tag_regex).and(:id.nin => removed_ids).page(params[:page]).per(per_page_preference)
  end

  def sale_category
    category_array = (params[:sub_category].present? ? [/^#{params[:category]}$/i, /^#{params[:sub_category]}$/i] : [/^#{params[:category]}$/i])
    featured_products = current_site.contents.published.where(:categories.all => category_array).and(:_type => 'ProductCategory').with_size(categories: (params[:sub_category].present? ? 2 : 1)).first
    removed_ids = featured_products ? featured_products.linked_contents.collect { |lc| lc.linked_content_id } : []
    @product_category = featured_products unless params[:page] && params[:page].to_i > 1
    @products = products.published.not_archived.where(tags: /sale/i).and(:categories => category_regex, :categories => sub_category_regex, :id.nin => removed_ids).page(params[:page]).per(per_page_preference)
  end

  def feature
    @content = current_site.contents.where(:_type.in=>['Selection','Footnote']).where(:basename=>/^#{params[:basename]}$/i).first
    if @content
      redirect_to @content.friendly_path
    else
      redirect_to selections_path
    end
  end

  def selections
    all_selections = current_site.contents.published.where(:_type=>'Selection').not.lte(end_time: Time.now)
    @featured_selections = all_selections.shift(2)
    @selections = all_selections.skip(2)
  end

  def selection
    @selection = current_site.contents.where(:_type=>'Selection').find_by(:basename=>/^#{params[:basename]}$/i)
    @related_selections = @selection.related_selections(4)
  end

  def personal_selection
    @personal_selection = current_site.contents.where(:_type=>'PersonalSelection').find_by(:basename=>/^#{params[:basename]}$/i)
    @recent_selections = current_site.contents.published.where(:_type=>'Selection').not.lte(end_time: Time.now).limit(4)
  end

  def product
    @enable_nav_highlighting_for_product = true
    @product=current_site.contents.where(:_type=>'Product').find_by(:basename=>/^#{params[:basename]}$/i)
    # needs migration and/or callbacks to titleize categories in mongo (right now some are some aren't), until then:
    @product.categories.map! { |category| category.titleize }
  end

  def product_stock
    @products = products.where(:spree_product_id.in => params[:spree_product_ids])
  end

  def search
    begin
      @site_id = current_site.id
      if params[:type]
        @results = ClearCMS::Content.type_search(params, @site_id, per_page_preference)
        @results_type = params[:type].strip.downcase
      else
        @products_search=Product.boosted_search(search: params[:search], page: 1, per_page: 20, site_id: @site_id)
        @products=@products_search.results
        @stories_search=ClearCMS::Content.boosted_search(type: ['Chapter', 'Footnote'], search: params[:search], page: 1, per_page: 8, site_id: @site_id)
        @stories=@stories_search.results
        @selections_search=Selection.boosted_search(search: params[:search], page: 1, per_page: 8, site_id: @site_id)
        @selections=@selections_search.results
        @results_type = 'unfiltered'
      end
    rescue Net::OpenTimeout, RSolr::Error::Http => e
      Airbrake.notify(e)
      render 'static/search_error', :status => 500
    end
  end

  def designers
    @fashion_brands=Brand.where(:id.in=>Product.published.where(:categories.in=>[/^fashion$/i]).pluck(:brand_id)).where(:hide_from_designer_index.ne=>true).asc(:title)
    @home_brands=Brand.where(:id.in=>Product.published.where(:categories.in=>[/^home$/i]).pluck(:brand_id)).where(:hide_from_designer_index.ne=>true).asc(:title)
    @beauty_brands=Brand.where(:id.in=>Product.published.where(:categories.in=>[/^beauty$/i]).pluck(:brand_id)).where(:hide_from_designer_index.ne=>true).asc(:title)
    @art_brands=Brand.where(:id.in=>Product.published.where(:categories.in=>[/^art$/i]).pluck(:brand_id)).where(:hide_from_designer_index.ne=>true).asc(:title)
  end

  def new
    @products=products.published.listed.recently_available.page(params[:page]).per(per_page_preference)
  end

private

  def category_regex
    /^#{params[:category]=='all' ? '.*' : params[:category]}$/i
  end

  def sub_category_regex
    /^#{params[:sub_category].blank? || params[:sub_category]=='all' ? '.*' : params[:sub_category]}$/i
  end

  def tag_regex
    /^#{params[:tag]=='all' ? '.*' : params[:tag]}$/i
  end

  def sub_tag_regex
    /^#{params[:sub_tag].blank? || params[:sub_tag]=='all' ? '.*' : params[:sub_tag]}$/i
  end

  def record_shopping_view
    session[:shop_view_count] = session[:shop_view_count] ? session[:shop_view_count] += 1 : 1
  end

end
