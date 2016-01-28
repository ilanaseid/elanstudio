module Spree
  class ProcessPayments
    include Sidekiq::Worker

    sidekiq_options throttle: { threshold: 1, period: 2.minutes }, :retry => true

    def perform(order_id)
      logger.info "Checking order state for order #{order_id}"
      order=Spree::Order.find(order_id)
      bp_order = Brightpearl::OrderService::Order.find(order.brightpearl_order_id)

      if [19,23,34,39,35,28,40].include?(bp_order.orderStatus.orderStatusId) #Shipped!, SPECIAL ORDER - Soho,Ecom,LA, SHIPS FROM VENDOR - Soho,Ecom,LA-- see all codes under brightpearl webhooks controller
        logger.info "Brightpearl order in orderStatus of either 19,34,23,35,28, so processing payments"
        if order.state=='complete' && (order.payment_state=='balance_due' || order.payments.pending.any?)
          logger.info "Processing payments for order #{order_id}"
          order.payments.pending.each {|p| p.capture! }
          order.shipments.ready.each {|s| s.ship! }
        else
          logger.info "Order was not in the correct state #{order} - sending to Airbrake."
          Airbrake.notify("Order was in wrong state for processing payment",:error_message=>"Order #{order.number} is in the wrong state for processing a payment #{order.inspect}")
        end
      else
        logger.info "Brightpearl order was not in orderStatus of 19: Shipped!, instead was #{bp_order.orderStatus.orderStatusId}. Spree Order id: #{order_id} / BP: #{order.brightpearl_order_id}"
      end

    end

  end
end


