module Spree
  class ProcessShipment
    include Sidekiq::Worker

    sidekiq_options throttle: { threshold: 1, period: 2.minutes }, :retry => true


    def perform(goods_out_note_id)
      goods_out_note = Brightpearl::WarehouseService::GoodsOutNote.get(goods_out_note_id)

      logger.info "Found goods out note: #{goods_out_note}"

      if goods_out_note['status']['shipped']
        order = Spree::Order.find_by_brightpearl_order_id(goods_out_note['orderId'])
        if !order.nil?
          logger.info "Goods out note showing status of shipped, adding tracking information to order with BP order id: #{goods_out_note['orderId']}"
          shipment = order.shipments.first
          shipment.tracking = goods_out_note['shipping']['reference']
          shipment.shipped_at = goods_out_note['status']['shippedOn']
          shipment.save! # for debugging would like to see if this fails.

          if order.payment_state=='paid' && order.shipment_state!='shipped'
            logger.info "Shipping shipment for #{order.inspect}"
            shipment.ship! if shipment.ready?
          end
        else
          logger.info "There was no associated Spree Order for this goods out note (#{goods_out_note_id}): #{goods_out_note}"
        end

      end

    end

  end
end
