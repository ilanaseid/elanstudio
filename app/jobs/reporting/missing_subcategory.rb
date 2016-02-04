module Reporting
  class MissingSubcategory
    include Sidekiq::Worker

    def perform(email='ilana@elanstudio.com')
      CSV.open("missing_subcategory.csv","wb") {|csv| Product.published.where(:categories.with_size=>2).where(:categories.nin=>[/art/i]).each {|p| csv << [p.title,p.brightpearl_sku,p.publish_at,p.friendly_path,p.categories] }}
      attachments=[{:name=>'missing_subcategory.csv', :content=>File.read('missing_subcategory.csv')}]
      SystemMailer.general("#{email}",'Products Missing Subcategories', 'Please find attached the CSV of products missing subcategories.', attachments).deliver
    end

  end
end
