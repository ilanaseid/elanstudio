require 'clockwork'

require './config/boot'
require './config/environment'

module Clockwork

  configure do |config|
    config[:logger] = Rails.logger
    config[:tz] = 'EST'
  end

  error_handler do |error|
    Airbrake.notify_or_ignore(error)
  end

  every(15.minutes, 'gc.stats') { Utility::Stats.perform_async }

  every(1.hour, 'brightpearl.sync_products', :at=>((10..18).collect{|n| "#{n}:00"}) ) { Brightpearl::SyncProducts.perform_async }

  every(1.day, 'cms.set_selection_sort_weight', :at => ['00:00']) { CMS::SetSelectionSortWeight.perform_async }
  every(1.day, 'reporting.completed_orders_without_brightpearl_id', :at =>'04:00') { Reporting::CompletedOrdersWithoutBrightpearlId.perform_async }
  every(1.day, 'reporting.product_feed', :at=>['09:00']) { Reporting::ProductFeed.perform_async }
  every(1.day, 'spree.process_ready_order_payments', :at =>'20:00') { Spree::ProcessReadyOrderPayments.perform_async }
  every(1.day, 'trigger_emails.product_notification_mailer', :at => ['09:00','14:00']) { TriggerEmails::ProductNotificationMailer.perform_async }

  every(1.week, 'reporting.archived_products_with_stock', :at=>'Sunday 10:00') { Reporting::ArchivedProductsWithStock.perform_async }
  every(1.week, 'reporting.chapter_product_feature', :at=>'Sunday 9:30') { Reporting::ChapterProductFeature.perform_async }
  every(1.week, 'reporting.missing_subcategory', :at=>'Sunday 11:00') { Reporting::MissingSubcategory.perform_async }
  every(1.week, 'reporting.product_publish', :at=>'Sunday 09:00') { Reporting::ProductPublish.perform_async }
  every(1.week, 'reporting.product_status', :at=>'Sunday 10:30') { Reporting::ProductStatus.perform_async }
  every(1.week, 'reporting.sold_out_products_marked_current', :at=>'Sunday 11:30') { Reporting::SoldOutProductsMarkedCurrent.perform_async }

end
