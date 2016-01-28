Spree::Core::ControllerHelpers::Order.class_eval do 

  def set_current_order
    logger.debug "In overridden order controller helper #{__FILE__}"
    if user = try_spree_current_user
      last_incomplete_order = user.last_incomplete_spree_order
      if cookies.permanent.signed[:guest_token].nil? && last_incomplete_order
        cookies.permanent.signed[:guest_token] = last_incomplete_order.guest_token
      elsif current_order(create_order_if_necessary: true) && last_incomplete_order && current_order != last_incomplete_order
        current_order.merge!(last_incomplete_order)
      end
      
      user.orders.incomplete.where('id!=?',current_order.id).each do |order|
        current_order.merge!(order)
      end
      
      #associate_user
    end    
  end
  
end