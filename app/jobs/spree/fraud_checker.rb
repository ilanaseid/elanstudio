module Spree
  class FraudChecker
  include Sidekiq::Worker

    def perform(order_id)
      order = Spree::Order.find(order_id)
      FraudNotifier.new(order).deliver
    end

  end
end
