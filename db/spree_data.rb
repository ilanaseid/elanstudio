#Setup default spree admin user
spree_admin_user=Spree::User.new(:firstname=>'Systems', :lastname=>'User', :email=>'ilana@elanstudio.com', :password=>'0p3ns3s4m3')
spree_admin_user.spree_roles << Spree::Role.find_by_name('admin')
spree_admin_user.save


#Setup default cms admin user
cms_admin_user=ClearCMS::User.create(:email=>'ilana@elanstudio.com', :base_name=>'systems', :full_name=>'Systems', :short_name=>'systems', :password=>'0p3ns3s4m3', :system_permission=>'administrator')

#Setup default cms site
default_site=ClearCMS::Site.create(:domain=>'elanstudio.com', :slug=>'elanstudio', :name=>'Elan Studio')

#####Setup a bunch of Spree required defaults
stock_location=Spree::StockLocation.create(:name=>'81 Walker Street - 2nd Floor')

shipping_category=Spree::ShippingCategory.create(:name=>'Default Shipping Category')

#Second-Day Shipping
second_day_shipping_method=Spree::ShippingMethod.new(:name=>"2nd-Day Free Shipping", :zones=>Spree::Zone.all.collect.to_a, :calculator_type=>"Spree::Calculator::Shipping::FlatRate")
second_day_shipping_method.shipping_categories << shipping_category
second_day_shipping_method.save
second_day_shipping_method.calculator.preferred_amount=0.0
second_day_shipping_method.calculator.preferred_currency='USD'

#Next-Day Shipping
next_day_shipping_method=Spree::ShippingMethod.new(:name=>"Next-Day Shipping", :zones=>Spree::Zone.all.collect.to_a, :calculator_type=>"Spree::Calculator::Shipping::FlatRate")
next_day_shipping_method.shipping_categories << shipping_category
next_day_shipping_method.save
next_day_shipping_method.calculator.preferred_amount=25.0
next_day_shipping_method.calculator.preferred_currency='USD'


payment_methods=Spree::Gateway::BraintreeGateway.create(name: Settings.braintree.name, active: true, display_on: '')
payment_methods.set_preference :merchant_id, Settings.braintree.merchant_id
payment_methods.set_preference :public_key, Settings.braintree.public_key
payment_methods.set_preference :private_key, Settings.braintree.private_key
payment_methods.set_preference :client_side_encryption_key, Settings.braintree.client_side_encryption_key
#####


#TODO: Joel
#Add Taxes/Tax Zones for NYS
