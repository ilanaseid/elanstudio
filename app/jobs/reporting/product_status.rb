module Reporting
  class ProductStatus
    include ApplicationHelper
    include Sidekiq::Worker

    def product_status_label_text(product)
      product_status=product_status(product)
      if product_status.present?
        return "#{I18n.t('product.status_'+product_status)}"
      else
        return ''
      end
    end

    def perform(email='ilana@elanstudio.com')
      CSV.open("product_status.csv","wb") {|csv|
        Product.published.each {|p| csv << ["https://www.elanstudio.com"+ p.friendly_path, p.brightpearl_sku, product_status(p), product_status_label_text(p)] }}
      attachments=[{:name=>'product_status.csv', :content=>File.read('product_status.csv')}]
      SystemMailer.general("#{email}",'Product Status Report', 'Please find attached the CSV of products with current status.', attachments).deliver
    end

  end
end
