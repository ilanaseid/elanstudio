xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0",
  'xmlns:content'=>"http://purl.org/rss/1.0/modules/content/",
  'xmlns:dc'=>"http://purl.org/dc/elements/1.1/",
  'xmlns:media'=>"http://search.yahoo.com/mrss/",
  'xmlns:atom'=>"http://www.w3.org/2005/Atom",
  'xmlns:georss'=>"http://www.georss.org/georss" do
  xml.channel do
    xml.title "#{t('site.the_line')} - #{t('site.nav.editorial')}"
    xml.link "#{Settings.canonical_url_root}#{stories_path}"
    xml.description t('site.stories_meta_description')
    xml.language 'en-us'
    xml.tag! 'atom:link', :rel=>'self', :type =>'application/rss+xml', :href=>"#{Settings.canonical_url_root}#{stories_path(:format=>'xml')}"
    @stories.each do |story|
      xml.item do
        xml.title story.title
        xml.link "#{Settings.canonical_url_root}#{story.friendly_path}"
        xml.guid "#{story.id}-v1", :isPermaLink => false
        xml.pubDate story.publish_at.to_s(:rfc822)
        xml.description story.short_description
        xml.content:encoded do
          xml.cdata! strip_custom_markup(story.content_block('raw').try(:body))
        end
      end
    end
  end
end
