class NormalizeProductNotificationEmails < ActiveRecord::Migration
  class ProductNotification < ActiveRecord::Base
    # Needed because:
    # http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  end

  def change
    ProductNotification.reset_column_information
    reversible do |dir|
      dir.up do
        ProductNotification.all.each do |notification|
          notification.email = notification.email.strip.downcase
          notification.save!
        end
      end
    end
  end
end
