module Utility
  class Content 
    def self.rebuild_image_width_height
      ClearCMS::Content.all.each do |content|
        content.content_blocks.each do |cb|
          cb.content_assets.each do |ca|
            file=ca.mounted_file.file.authenticated_url
            begin 
              img=MiniMagick::Image.open file  
              ca.update_attributes(:width=>img[:width], :height=>img[:height])
            rescue => e 
              puts file 
              puts e 
            end
          end     
        end
      end
    end
    
  end
end