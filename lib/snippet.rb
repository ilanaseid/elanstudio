class Snippet
  @html_sources={}
  
  Dir.glob(File.join Rails.root,'spec/snippets/**/*.html') do |file|
    file_key=file.match(/.*snippets\/(.*\/.*)\/.*\.html/)
    file_key=file_key.nil? ? 'unresolved' : file_key[1]
    @html_sources[file_key] ||= []
    @html_sources[file_key] << File.read(file) 
  end  
  
  def self.random_html(key)
    @html_sources[key] ? @html_sources[key][Random.rand(@html_sources[key].length)] : Faker::Lorem.paragraph(20)
  end
  
  def self.html_sources
    @html_sources
  end

end