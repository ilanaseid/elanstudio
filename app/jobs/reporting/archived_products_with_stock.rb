module Reporting
  class ArchivedProductsWithStock
    include Sidekiq::Worker

    def perform(email='merchandising@theline.com')

      titles = ['title','brightpearl_sku','publish_at','URL','categories']
      # add each stock location to title array
      Spree::StockLocation.all.each {|l| titles << l.name.to_s + ' Count' }

      CSV.open("archived_products_with_stock.csv","wb") {|csv|

        csv << titles
        Product.published.where(:product_state.in=>['Discontinued','Hidden']).each do |p|
          if p.available_any_location?
            line_items = [p.title,
                          p.brightpearl_sku,
                          p.publish_at,
                          Settings.canonical_url_root + p.friendly_path,
                          p.categories]
            # add each stock location count to line items array
            Spree::StockLocation.all.each {|l| line_items << p.spree_product.stock_items.where(:stock_location_id => l.id).to_a.sum(&:count_on_hand) }
            # push all into csv
            csv << line_items
          end
        end
      }
      attachments=[{:name=>'archived_products_with_stock.csv', :content=>File.read('archived_products_with_stock.csv')}]
      SystemMailer.general("#{email}",'Report of Archived Products With Stock', 'Please find attached the CSV of archived products with stock.', attachments).deliver
    end
  end
end
