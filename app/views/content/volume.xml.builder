xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0",
  'xmlns:content'=>"http://purl.org/rss/1.0/modules/content/",
  'xmlns:dc'=>"http://purl.org/dc/elements/1.1/",
  'xmlns:media'=>"http://search.yahoo.com/mrss/",
  'xmlns:atom'=>"http://www.w3.org/2005/Atom",
  'xmlns:georss'=>"http://www.georss.org/georss" do
  xml.channel do
    xml.title "#{t('site.nav.editorial')} — #{t('site.the_line')}"
    xml.link "#{Settings.canonical_url_root}#{@volume.friendly_path}"
    xml.description strip_tags(@volume.content_block('raw').try(:body))
    xml.language 'en-us'
    xml.tag! 'atom:link', :rel=>'self', :type =>'application/rss+xml', :href=>"#{Settings.canonical_url_root}#{@volume.friendly_path}.xml"
    @chapters.each do |chapter|
      xml.item do
        xml.title chapter.title
        xml.link "#{Settings.canonical_url_root}#{chapter.friendly_path}"
        xml.guid "#{chapter.id}-v1", :isPermaLink => false
        xml.pubDate chapter.publish_at.to_s(:rfc822)
        xml.description chapter.short_description
        xml.content:encoded do
          xml.cdata! strip_custom_markup(chapter.content_block('raw').try(:body))
        end
      end
    end
  end
end
