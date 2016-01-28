module Brightpearl
  class SyncProducts
    include Sidekiq::Worker
  
    sidekiq_options throttle: { threshold: 1, period: 20.minutes }, :retry => false
  
    def perform
    
      if Settings.brightpearl.disable_sync
        logger.info "Brightpearl is set to disable sync, not syncing."
        return
      end
    
      ActiveRecord::Base.connection.cache do 
        logger.info 'Syncing products from Brightpearl'
        Utility::Brightpearl.clear_cache #class cache, not redis related
        Utility::Brightpearl.sync_products
        Utility::Brightpearl.clear_cache
      end
    end
  end
end