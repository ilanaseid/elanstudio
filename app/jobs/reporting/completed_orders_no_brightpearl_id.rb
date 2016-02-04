module Reporting
  class CompletedOrdersWithoutBrightpearlId
    include Sidekiq::Worker

    def perform(email='ilana@elanstudio.com')
      orders_without_bp_id = Spree::Order.where.not(completed_at: nil, state: 'canceled').where(brightpearl_order_id: nil)
      if orders_without_bp_id.length > 0
        CSV.open("completed_orders_without_brightpearl_id.csv","wb") do |csv|
          csv << ["Spree Order Number", "Completed At", "Order State", "Payment State"]
          orders_without_bp_id.each {|o| csv << [o.number, o.completed_at, o.state, o.payment_state] }
        end
        attachments=[{:name=>'completed_orders_without_brightpearl_id', :content=>File.read('completed_orders_without_brightpearl_id.csv')}]
        SystemMailer.general("#{email}",'Spree Orders Not Yet in Brightpearl', 'The following Spree orders are not yet in Brightpearl.  Cancelled orders are excluded from this report.', attachments).deliver
      end
    end

  end
end
