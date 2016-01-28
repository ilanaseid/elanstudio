module Reporting
  class ProductFeed
    include Sidekiq::Worker

    sidekiq_options throttle: { threshold: 1, period: 5.minutes }, :retry => false

    def perform(*args)
      ProductFeedGenerator.new(*args).publish
    end
  end
end
