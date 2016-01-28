ClearCMS::Uploaders::ContentAssetUploader.class_eval do

  #remove cms defined versions
  self.versions = {}

  version :full do
    process :resize_to_fit_with_quality=>[1985,nil,70]
  end


  version :large, :from_version=>:full do
    process :resize_to_fit_with_quality=>[1229,nil,70]
  end


  version :medium, :from_version=>:large do
    process :resize_to_fit_with_quality=>[977,nil,70] {|img| img.adaptive_sharpen("0x0.6") } #TODO: figure out how to inject this block
    #process :adaptive_sharpen=>[0,0.6]
  end


  version :grid, :from_version=>:large do
    process :resize_to_fit_with_quality=>[473,nil,70] {|img| img.adaptive_sharpen("0x0.6") }
    #process :adaptive_sharpen=>[0,0.6]
  end


  version :thumb, :from_version=>:large do
    process :resize_to_fit_with_quality=>[95,nil,70]
  end


#   version :index do
#     process :resize_to_fit_with_quality=>[1481,nil,70]
#   end


#   version :index_cropped do
#     process :resize_to_fill_with_quality=>[1481,494,70]
#   end


  def adaptive_sharpen(radius=0,sigma=0.6)
    manipulate! do |img|
      img.adaptive_sharpen("#{radius}x#{sigma}")
      img
    end
  end

  def default_url
    "/assets/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  def self.version_list
    [
      {:prefix=>'full', :label=>'Full (15c-16c)', :default=>false},
      {:prefix=>'large', :label=>'Large (10c-14c)', :default=>true},
      {:prefix=>'medium', :label=>'Medium (7c-9c)', :default=>false},
      {:prefix=>'grid', :label=>'Grid (1c-6c)', :default=>false}
    ]
  end

end
