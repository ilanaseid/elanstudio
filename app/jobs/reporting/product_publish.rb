module Reporting

  class ProductPublish
    include Sidekiq::Worker

    def perform(email='ilana@elanstudio.com')
      CSV.open("product_publish.csv","wb") {|csv| Product.published.each {|p| csv << [p.title,p.brightpearl_sku,p.publish_at,p.friendly_path] }}
      attachments=[{:name=>'product_published.csv', :content=>File.read('product_publish.csv')}]
      SystemMailer.general("#{email}",'Product Publish Dates Report', 'Please find attached the CSV of CMS publish dates for products.', attachments).deliver
    end

  end
end
