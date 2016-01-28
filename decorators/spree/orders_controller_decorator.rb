Spree::OrdersController.class_eval do

  respond_to :html, :json

  def index
    authorize! :edit, spree_current_user

    @orders = spree_current_user.orders.complete.order('completed_at desc')
  end

  def populate
    order    = current_order(create_order_if_necessary: true)
    variant  = Spree::Variant.find(params[:variants].first[0])
    quantity = params[:variants].first[1].to_i
    options  = params[:options] || {}

    # 2,147,483,647 is crazy. See issue #2695.
    if quantity.between?(1, 2_147_483_647)
      begin
        order.contents.add(variant, quantity, options)
      rescue ActiveRecord::RecordInvalid => e
        error = e.record.errors.messages.values.join(", ")
      end
    else
      error = Spree.t(:please_enter_reasonable_quantity)
    end

    respond_with(order) do |format|
      if error
        flash[:error] = error
        format.html { redirect_back_or_default(spree.root_path) }
        format.json { redirect_to cart_path(format: :json) }
      else
        format.html { redirect_to cart_path }
        format.json { redirect_to cart_path(format: :json) }
      end
    end
  end

  def update
    if @order.contents.update_cart(order_params)
      respond_with(@order) do |format|
        format.html do
          if params.has_key?(:checkout)
            @order.next if @order.cart?
            redirect_to checkout_state_path(@order.checkout_steps.first)
          else
            redirect_to cart_path
          end
        end
        format.json do
          redirect_to cart_path(:format=>:json)
        end
      end
    else
      respond_with(@order) do |format|
        format.json { redirect_to cart_path(:format=>:json) }
      end
    end
  end


  # Shows the current incomplete order from the session
  def edit
    @order = current_order(create_order_if_necessary: true)
    @gifts = products.published.listed.without_options.where(tags: 'gifts').random(4)
    associate_user
#     respond_with(@order) do |format|
#       #format.js {render :text=>'OK'}
#       #format.json {render :json=>@order}
#     end
  end

end
