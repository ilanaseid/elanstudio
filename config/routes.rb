Elanstudio::Application.routes.draw do

  require 'sidekiq/web'
  admin = lambda { |r| r.env["warden"].authenticate? && Ability.new(r.env['warden'].user).can?(:manage, Sidekiq) }
  constraints admin do
    mount Sidekiq::Web => '/sidekiq'
  end
  
  root :to => 'content#page'

  ### Loft routes
  get 'showrooms' => 'content#showrooms', as: :showrooms
  get 'showrooms/:basename' => 'content#showroom', as: :showroom
  get 'event/:basename' => 'content#event', as: :event

  get '/404' => 'static#status_404', as: :status_404
  get '/500' => 'static#status_500', as: :status_500
  get '/503' => 'static#status_500', as: :status_503

  resources :showroom_requests
  resources :showroom_visits
  resources :email_subscribers, :only => [:new, :create, :update]
  resources :product_notifications, only: [:show, :new, :create]
  resources :support_requests
  resources :wishlist_items

  get 'newsletter/edit' => 'email_preferences#edit', as: :edit_email_preference
  post 'newsletter/edit' => 'email_preferences#update', as: :update_email_preference

  #CMS Types with Permalink Paths
  get 'brand/:basename' => 'content#brand', as: :brand
  get 'shop/product/:basename' => 'shop#product', :as => :product
  get 'product_tag/:basename' => 'content#product_tag', :as => :product_tag
  get 'product_category/:basename' => 'content#product_category', as: :product_category
  get 'editorial/:basename' => 'content#editorial', as: :editorial
  get 'page/:basename' => 'content#page', as: :page
  get 'stories' => 'content#stories', as: :stories
  #get 'site_messaging/:basename' => 'content#site_messaging', as: :site_messaging
  
  #CMS Generic Routes
  get 'content/packaging_exceptions' => 'content#packaging_exceptions'
  get 'content/returns_policy' => 'content#returns_policy'
  get 'content/feedback' => 'content#feedback'
  get 'content/contact' => 'content#contact'
  get 'content/:category' => 'content#category', as: :content_category
  get 'content/:category/:basename' => 'content#show', as: :content_category_page
  get 'content/:id' => 'content#show', :as => :content
  resources :content

  #Shop Specific Routes
  get 'shop/search' => 'shop#search', :as => :shop_search
  get 'shop/designers_index' => 'shop#designers', :as => :shop_designers
  get 'shop/product/:basename' => 'shop#product', :as => :shop_product
  get 'shop/product_stock' => 'shop#product_stock', :as => :shop_product_stock
  get 'shop/notifyme/:basename' => 'shop#notifyme', :as => :shop_notifyme
  get 'shop/wishlist/:basename' => 'shop#wishlist', :as => :shop_wishlist
  get 'shop/tag/:tag(/:sub_tag)' => 'shop#tag', :as => :shop_tag
  get 'shop/sale/:category(/:sub_category)' => 'shop#sale_category', :as => :shop_sale_category
  get 'shop/new' => 'shop#new', :as => :shop_new
  get 'shop/:category(/:sub_category)' => 'shop#category', :as => :shop_category
  get 'shop' => 'shop#category', :as => :shop_index, :category=>'all'

  #Reports Routes
  get 'reports' => 'reports#index'
  post 'reports' => 'reports#create'
  post 'reports/user_purchase_data' => 'reports#user_purchase_data'

  #Static Content Catch-all
  get '/s/:action(:format)', :controller=>'static', :as=>:static_content

  mount ClearCMS::Engine, at: '/clear_cms'

  mount Spree::Core::Engine, :at => '/'

  get '/orders', :controller=>'spree/orders', :action=>:index, :as=>:order_history

end
