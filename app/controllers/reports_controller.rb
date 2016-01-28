class ReportsController < ApplicationController

  def index
    authorize! :manage, Reporting
    @user = spree_current_user
    @reports = Reporting.constants.sort.map { |report| [report.to_s.titleize, report] }
  end

  def create
    authorize! :manage, Reporting
    email = params[:email]
    report_name = params[:report_name]
    if "Reporting::#{report_name}".constantize.perform_async(email)
      flash[:notice] = "#{report_name.titleize} Report running. Will send to #{email}."
    else
      flash[:notice] = "There was an error sending the report"
    end
    redirect_to action: 'index'
  end

  def user_purchase_data

    if Spree::Order.complete.where(email: params[:email]).any?
      #eager loading line items
      orders = Spree::Order.complete.where(email: params[:email]).includes(:line_items)
      @location = orders.last.bill_address.city + ", " + orders.last.bill_address.state.name + " (Billing) OR "  + orders.last.ship_address.city + ", " + orders.last.ship_address.state.name + "(Shipping)"
      @cms_products = []
      @sizes_array = []

      orders.each do |order|
        order.line_items.each do |line_item|
          @cms_products << line_item.product.cms_product
          @sizes_array << line_item.variant.option_values.collect {|o| o.presentation }.join(' - ')
        end
      end

      @sizes_array = @sizes_array.uniq!
      @sizes_array = @sizes_array.nil? ? ['OS'] : @sizes_array.sort!
      generate_user_info(@cms_products)

    elsif RetailStaffOrderDetail.where(customer_id: params[:email]).pluck(:spree_order_id).any?
      retail_staff_order_ids = RetailStaffOrderDetail.where(customer_id: params[:email]).pluck(:spree_order_id)
      orders = Spree::Order.complete.find(retail_staff_order_ids.compact)
      @location = orders.last.bill_address.city + ", " + orders.last.bill_address.state.name + " (Billing) OR "  + orders.last.ship_address.city + ", " + orders.last.ship_address.state.name + "(Shipping)"
      @cms_products = []
      @sizes_array = []

      orders.each do |order|
        order.line_items.each do |line_item|
          @cms_products << line_item.product.cms_product
          @sizes_array << line_item.variant.option_values.collect {|o| o.presentation }.join(' - ')
        end
      end

      @sizes_array = @sizes_array.uniq!
      @sizes_array = @sizes_array.nil? ? ['OS'] : @sizes_array.sort!
      generate_user_info(@cms_products)

    else
      # no orders for that email address in spree - needs to flash message and stay on reports index page
      redirect_to action: 'index', :notice => "No user with that email in Spree."
    end
  end

  def generate_user_info(cms_products)
      primary_categories = []
      subcategories = []
      brands = []
      prices_array = []

      cms_products.each do |cms_product|
        primary_categories << cms_product.primary_category
        subcategories << cms_product.first_subcategory
        brands << cms_product.brand.title
        prices_array << cms_product.price
      end

      primary_categories_count_hash = primary_categories.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
      sub_categories_count_hash = subcategories.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
      brand_count_hash = brands.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }

      @cms_products = cms_products
      @unique_primary_categories = Hash[primary_categories_count_hash.sort_by{|k, v| v}.reverse]
      @unique_subcategories = Hash[sub_categories_count_hash.sort_by{|k, v| v}.reverse]
      @unique_brands = Hash[brand_count_hash.sort_by{|k, v| v}.reverse]

      # Prices Hash
      range_array = ["$0 - $50", "$50 - $100", "$100 - $250", "$250 - $500", "$500 - $1000", "$1000 - $1500", "$1500+"]
      @price_distribution_hash = Hash[range_array.map {|x| [x, 0]}]

      prices_array.each do |p|
        if p <= 50
          @price_distribution_hash["$0 - $50"] += 1
        elsif p <= 100
          @price_distribution_hash["$50 - $100"] += 1
        elsif p <= 250
          @price_distribution_hash["$100 - $250"] += 1
        elsif p <= 500
          @price_distribution_hash["$250 - $500"] += 1
        elsif p <= 1000
          @price_distribution_hash["$500 - $1000"] += 1
        elsif p <= 1500
          @price_distribution_hash["$1000 - $1500"] += 1
        else
          @price_distribution_hash["$1500+"] += 1
        end
      end
  end
end
