module Brightpearl
  class ResetStockLevels
    include Sidekiq::Worker
  
    sidekiq_options throttle: { threshold: 1, period: 5.minutes }, :retry => false
  
    def perform
      logger.info 'Resetting stock levels from Brightpearl'
      
      Utility::Brightpearl.check_stock_levels
    end
  end
end





#r=Brightpearl::OrderService::OrderSearch.get('?orderStatusId=1')
#r["response"]["metaData"]["resultsAvailable"]==0

