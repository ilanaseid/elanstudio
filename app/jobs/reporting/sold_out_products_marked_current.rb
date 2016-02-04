module Reporting
  class SoldOutProductsMarkedCurrent
    include Sidekiq::Worker

    def perform(email='ilana@elanstudio.com')

      titles = ['title','brightpearl_sku','publish_at', 'updated_at', 'URL', 'categories', 'published?']
      # add each stock location to title array
      Spree::StockLocation.all.each {|l| titles << l.name.to_s + ' Count' }

      CSV.open("sold_out_products_marked_current.csv","wb") {|csv|

        csv << titles
        Product.where(:product_state.in=>['Current']).each do |p|
          if !p.available_any_location?
            line_items = [p.title,
                          p.brightpearl_sku,
                          p.publish_at,
                          p.spree_product.updated_at,
                          Settings.canonical_url_root + p.friendly_path,
                          p.categories,
                          p.published? ]
            # add each stock location count to line items array
            Spree::StockLocation.all.each {|l| line_items << p.spree_product.stock_items.where(:stock_location_id => l.id).to_a.sum(&:count_on_hand) }
            # push all into csv
            csv << line_items
          end
        end
      }
      attachments=[{:name=>'sold_out_products_marked_current.csv', :content=>File.read('sold_out_products_marked_current.csv')}]
      SystemMailer.general("#{email}",'Report of Sold Out Products in Current State', 'Please find attached the CSV of sold out products in current state.', attachments).deliver
    end
  end
end
