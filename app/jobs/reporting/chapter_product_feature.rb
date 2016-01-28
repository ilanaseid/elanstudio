module Reporting
  class ChapterProductFeature
    include Sidekiq::Worker

    def perform(email='charlie@theline.com')
      CSV.open("chapter_product_feature.csv","wb") {|csv| Chapter.published.each {|c| c.resolve_linked_contents.each {|p| csv << [c.title,c.publish_at,p.title,p.brightpearl_sku] }}}
      attachments=[{:name=>'chapter_product_feature.csv', :content=>File.read('chapter_product_feature.csv')}]
      SystemMailer.general("#{email}",'Chapter Product Feature', 'Please find attached the CSV of products featured in Chapters.', attachments).deliver
    end

  end
end
