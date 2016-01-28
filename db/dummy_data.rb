require 'pp'

#Load settings from ENV
# product_count=ENV['PRODUCT_COUNT'] ? ENV['PRODUCT_COUNT'].to_i : 5
# editorial_count=ENV['EDITORIAL_COUNT'] ? ENV['EDITORIAL_COUNT'].to_i : 5

ClearCMS::User.delete_all

spree_admin_user=FactoryGirl.create(:spree_admin_user, :email=>'test+admin@theline.com', :password=>'sesame')
spree_user=FactoryGirl.create(:spree_user, :email=>'test+user@theline.com', :password=>'sesame')

#TODO: doesn't work because of firstname/lastname validations that were added to user
#Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

site = ClearCMS::Site.find_or_create_by(:name=>'The Line', :slug=>'theline', :domain=>'theline.com')

pp site

user = ClearCMS::User.find_or_create_by(:email=>'joel@theline.com')

pp user

#Clear the CMS Content
ClearCMS::Content.delete_all

#Default Homepage Content
content=FactoryGirl.create(:published_page_content, basename: 'homepage', site: ClearCMS::Site.first)
apartment=FactoryGirl.create(:published_apartment_content, site: ClearCMS::Site.first)
