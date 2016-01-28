Spree::CheckoutController.class_eval do
  prepend_before_filter :check_registration, :except => [:registration, :update_registration]
  prepend_before_filter :check_authorization
#   before_filter :check_authorization #need to define this here because spree_auth was defining it but it was happening at the end of the request so we couldn't chain user in before_address
#   before_filter :setup_for_current_state

  def registration
    @user = Spree::User.new
    @user.email       = params[:invalid_user_email] if params[:invalid_user_email]
    @user.remember_me = params[:remember_me] if params[:remember_me]
  end

  def update_registration
    if params[:order][:email] =~ Devise.email_regexp && current_order.update_attribute(:email, params[:order][:email])
      Mailchimp::SubscribeNewsletter.perform_async(params[:order][:email], {'utm_source'=>session[:utm_source], 'utm_medium'=>session[:utm_medium]}) if params[:newsletter]
      redirect_to spree.checkout_path
    else
      flash.now[:guest_email_error] = t(:email_is_invalid, :scope => [:errors, :messages])
      @user = Spree::User.new
      @order.email = params[:order][:email] if params[:order] && params[:order][:email]
      render 'registration'
    end
  end

private

  def before_address
    logger.debug "overriding before_address to return user address on checkout if they have a previous one"

    # return unless @order.user.present?

    if @order.user.present?
      @order.bill_address ||= @order.user.default_bill_address
      if @order.checkout_steps.include? "delivery"
        @order.ship_address ||= @order.user.default_ship_address
      end
    else
      @order.bill_address ||= Spree::Address.build_default
      @order.ship_address ||= Spree::Address.build_default if @order.checkout_steps.include?('delivery')
    end

    #hack to keep these from being built when it's an update(PATCH) so that our reject_if=>all_blank works, otherwise it builds these and saves them anyway
    #spree calls before_address on all address actions, even on the submit for the next step to delivery etc
    unless params[:order]
      @order.retail_staff_order_detail || @order.build_retail_staff_order_detail
    end

    @order.gift_detail || @order.build_gift_detail

    @unshippable_products=[]
    if @order.ship_address_id && @order.ship_address.valid?
      shipments=@order.create_proposed_shipments
      no_shipments=shipments.select {|s| s if s.shipping_method.blank? }
      @unshippable_products=(no_shipments.any? ? no_shipments.collect{|s| s.to_package} : [])
    end

  end

  # Introduces a registration step whenever the +registration_step+ preference is true.
  def check_registration
    logger.debug "overriding check_registration to not allow through without spree_current user (previously was allowing if order had email but we want to force them to login)"
    return unless Spree::Auth::Config[:registration_step]
    if Spree::Config[:allow_guest_checkout]
      return if spree_current_user or current_order.email
    else
      return if spree_current_user #or current_order.email
    end
    store_location
    redirect_to spree.checkout_registration_path
  end

end
