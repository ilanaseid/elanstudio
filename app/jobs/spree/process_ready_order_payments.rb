module Spree
  class ProcessReadyOrderPayments
    include Sidekiq::Worker

    sidekiq_options throttle: { threshold: 1, period: 2.minutes }, :retry => true

    def perform(email='ilana@elanstudio.com')
      failed_payment_orders = Spree::Order.failed_payment
      credit_owed_orders = Spree::Order.where(:payment_state => 'credit_owed')

      payment_failed_order_ids = []
      credit_owed_order_ids = []

      # populate the failed orders first
      if failed_payment_orders.any?

        failed_payment_orders.each do |failed_payment_order|
          # make sure it has a bp order id first, so we don't throw 404 looking for nil.
          if !failed_payment_order.brightpearl_order_id.nil?
            payment_failed_order_ids << failed_payment_order.number
          else # if no brightpearl_order_id
            Airbrake.notify(Exception.new(msg: 'Completed order found without BP order id'), error_message: "An order with payment due that does not have BrightPearl order id was found by nightly ProcessReadyOrderPayments job.  This may resolve itself, but please keep eye on: #{failed_payment_order.number}")
          end # END IF order.brightpearl_order_id
        end

      end

      #do the credit owed orders
      if credit_owed_orders.any?
        credit_owed_orders.each do |credit_owed_order|
          # make sure it has a bp order id first, so we don't throw 404 looking for nil.
          if !credit_owed_order.brightpearl_order_id.nil?
            credit_owed_order_ids << credit_owed_order.number
          else # if no brightpearl_order_id
            Airbrake.notify(Exception.new(msg: 'Completed order found without BP order id'), error_message: "An order with credit owed that does not have BrightPearl order id was found by nightly ProcessReadyOrderPayments job.  This may resolve itself, but please keep eye on: #{credit_owed_order.number}")
          end # END IF order.brightpearl_order_id
        end
      end

      #Send the email for both
      if payment_failed_order_ids.any? || credit_owed_order_ids.any?
        SystemMailer.general("#{email}", "Spree Orders: Payment Failed or Credit Owed #{DateTime.now.to_date}", "The following order numbers have failed payments: #{payment_failed_order_ids}. The following orders have credit owed: #{credit_owed_order_ids}").deliver
      end
    end
  end
end
