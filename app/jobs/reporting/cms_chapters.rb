module Reporting
  class CmsChapters
    include Sidekiq::Worker

    def perform(email='ilana@elanstudio.com')
      CSV.open("cms_chapter.csv","wb") do |csv|
        csv << ["Title", "Basename", "Tags", "Categories"]
        Chapter.published.each {|c| csv << [c.title, c.basename, (c.tags.join(",")), (c.categories.join(","))] }
      end
      attachments=[{:name=>'cms_chapter.csv', :content=>File.read('cms_chapter.csv')}]
      SystemMailer.general("#{email}",'CMS Chapters Report', 'Please find attached the CSV of CMS chapters.', attachments).deliver
    end

  end
end
