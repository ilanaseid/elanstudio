require 'spec_helper'
require 'rails_helper'
#require "#{Rails.root}/app/jobs/trigger_emails/product_notification"

describe "ProductNotification" do
  describe "Trigger Emails" do

    before(:each) do
      chapter = FactoryGirl.create(:published_chapter_content)
      expect(chapter.basename).to_not eq(nil)

      product = FactoryGirl.create(:product_with_option_types)

      product.variants.each do |variant|
        variant.stock_items.each do |stock_item|
          stock_item.set_count_on_hand(0)
        end
      end

      @variant_1 = product.variants.first
      expect(@variant_1.in_stock?).to eq(false)
      @notification_1 = ProductNotification.create(name: "Bob Test", email: "notiFicatiOn_tEst@elanstudio.com ", spree_variant_id: @variant_1.id)

      @variant_2 = product.variants.last
      expect(@variant2).to_not eq(@variant_1)
      expect(@variant_2.in_stock?).to eq(false)
      @notification_2 = ProductNotification.create(name: "Bob Test", email: "notiFicatiOn_tEst@elanstudio.com ", spree_variant_id: @variant_2.id)
    end

    it "Normalizes the email before save" do
      @notification_3 = ProductNotification.create(name: "Bob Test", email: "notiFicatiOn_tEst@elanstudio.com ", spree_variant_id: @variant_1.id)
      expect(@notification_3.email).to eq("notification_test@elanstudio.com")
    end

    it "Only groups Variants that are in Stock at Default Location" do
      # everything starts out of stock everywhere.
      expect(@notification_1.spree_variant.total_on_hand).to be(0)
      expect(@notification_2.spree_variant.total_on_hand).to be(0)
      expect(@notification_1.spree_variant.default_location_count_on_hand).to be(0)
      expect(@notification_2.spree_variant.default_location_count_on_hand).to be(0)

      # give some stock to notification 1's stock items at ecomm warehouse
      @notification_1.spree_variant.stock_items.at_default_stock_location.each do |stock_item|
        stock_item.set_count_on_hand(4)
      end


      # give notification 2 some empty stock items at another location
      @notification_2.spree_variant.stock_items.each do |stock_item|
        stock_item.update(stock_location: FactoryGirl.create(:stock_location, :not_default))
      end

      # stupid ass spree devs added conditional_variant_touch so associated variants do not get reloaded except if count_on_hand changes to something besides zero. for "performance."
      @notification_2.spree_variant.stock_items.reload
      # add some stock to the other location (this fails if not reloaded above)
      @notification_2.spree_variant.stock_items.first.set_count_on_hand(1)

      # make sure Spree wasn't sneaky and propagated all the variants to the new location by default, (there should only be one stock item).
      expect(@notification_2.spree_variant.stock_items.length).to eq(1)

      # TODO: notifications need to get reloaded even if we collect_sendable? :(
      @notification_1.reload
      @notification_2.reload

      notifications = TriggerEmails::ProductNotificationMailer.collect_sendable

      # make sure we're working with accurate data
      # notification 1 variant - some global stock (not 0)
      expect(@notification_1.spree_variant.total_on_hand).to_not eq(0)
      # notification 1 variant - exactly 4 at ecomm
      expect(@notification_1.spree_variant.default_location_count_on_hand).to eq(4)
      # notification 2 variant - exactly 1 on hand globablly
      expect(@notification_2.spree_variant.total_on_hand).to eq(1)
      # notification 2 variant - ...but NONE on hand at ecomm location
      expect(@notification_2.spree_variant.default_location_count_on_hand).to eq(0)

      # make sure we only sent a notification for the in-stock item at default (ecomm) location
      expect(notifications["notification_test@elanstudio.com"].include?(@notification_2)).to eq(false)
      expect(notifications["notification_test@elanstudio.com"].include?(@notification_1)).to eq(true)
    end

    it "Correctly groups Product Notifications by Email" do
      @notification_1.spree_variant.stock_items.each do |stock_item|
        stock_item.set_count_on_hand(1)
      end

      @notification_2.spree_variant.stock_items.each do |stock_item|
        stock_item.set_count_on_hand(1)
      end

      notifications = TriggerEmails::ProductNotificationMailer.collect_sendable

      expect(notifications["notification_test@elanstudio.com"].length).to eq(2)
      expect(notifications["notification_test@elanstudio.com"].include?(@notification_1)).to eq(true)
      expect(notifications["notification_test@elanstudio.com"].include?(@notification_2)).to eq(true)
    end

    it "Makes sure notifications are saved as 'sent' when sent" do
      expect(@notification_1.sent_at).to eq(nil)
      TriggerEmails::ProductNotificationMailer.new.send_email_transactionally(@notification_1.email, [@notification_1])

      # switched to update_all in the transactional method, so it will NOT update the model in place, only the db
      # so we have to reload the model.
      @notification_1.reload

      expect(@notification_1.sent_at).to_not eq(nil)
      expect(@notification_1.sent_at.class).to eq(ActiveSupport::TimeWithZone)
    end

    it "Can strip duplicate variants from the array" do
      # a duplicate notification
      @notification_3 = ProductNotification.create(name: @notification_2.name, email: @notification_2.email, spree_variant_id: @notification_2.spree_variant_id)

      clean_notifications = TriggerEmails::ProductNotificationMailer.new.drop_duplicates([@notification_1, @notification_2, @notification_3])
      expect(clean_notifications).to eq([@notification_1, @notification_2])

      clean_notifications = TriggerEmails::ProductNotificationMailer.new.drop_duplicates([@notification_2, @notification_3])
      expect(clean_notifications).to eq([@notification_2])
    end

    it "Makes sure duplicates are still marked as sent_at, even if stripped from email" do
      # a duplicate notification
      @notification_3 = ProductNotification.create(name: @notification_2.name, email: @notification_2.email, spree_variant_id: @notification_2.spree_variant_id)
      expect(@notification_3.sent_at).to eq(nil)

      TriggerEmails::ProductNotificationMailer.new.send_email_transactionally(@notification_2.email, [@notification_2, @notification_3])

      @notification_3.reload

      expect(@notification_3.sent_at).to_not eq(nil)
      expect(@notification_3.sent_at.class).to eq(ActiveSupport::TimeWithZone)
    end

  end
end
