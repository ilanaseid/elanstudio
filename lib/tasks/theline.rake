namespace :theline do
  namespace :recreate_test_images do 
    desc 'recreate all test images (product and editorial)'
    task :all => [:product,:editorial]
    desc 'recreate test images for products'
    task :product => [:environment] do 
      product=FactoryGirl.create(:product_content)
      (1..83).each do |n|
        begin
          puts "Product #{n}" 
          FactoryGirl.build(:content_asset, :content_block=>product.default_content_block, :file=>"image_#{n}.jpg").mounted_file.recreate_versions!
        rescue => e 
          puts "Error for: #{n} in product"
          puts e 
        end
      end
    end
    desc 'recreate test images for editorial'
    task :editorial => [:environment] do 
      editorial=FactoryGirl.create(:editorial_content)
      cb=editorial.default_content_block
      (1..123).each do |n|
        begin
          puts "Editorial #{n}"   
          FactoryGirl.build(:content_asset, :content_block=>editorial.default_content_block, :file=>"image_#{n}.jpg").mounted_file.recreate_versions!    
        rescue => e 
          puts "Error for: #{n} in editorial"
          puts e 
        end
      end    
    end
  
  end
  
  namespace :dummy_data do 
    desc 'load default dummy data'
    task :load => [:environment, 'db:setup'] do 
      require File.join Rails.root,'db/dummy_data'
    end
  
  end
  
  namespace :brightpearl do
    desc 'initial import of brightpearl data'
    task :import => [:environment, 'db:setup'] do 
      Theline::Brightpearl.full_import
    end
  end
  
end

namespace :clear_cms do 
  desc 'Remove content types that are not currently defined from MongoDB'
  task :cleanup_content => [:environment] do 
    delete_count=ClearCMS::Content.where(:_type.nin=>ClearCMS::Content.content_types).delete_all
    puts "Deleted #{delete_count}."
  end 
end