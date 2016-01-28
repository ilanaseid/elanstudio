class AddIndexSentAtToProductNotifications < ActiveRecord::Migration
  class ProductNotification < ActiveRecord::Base
    # Needed because:
    # http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  end

  def change
    ProductNotification.reset_column_information
    reversible do |dir|
      dir.up { ProductNotification.update_all sent_at: Time.now }
    end
    add_index :product_notifications, :sent_at
  end

end
