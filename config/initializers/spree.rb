# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'


Spree::ReturnItem::EligibilityValidator::Default.permitted_eligibility_validators = [
                                             Spree::ReturnItem::EligibilityValidator::OrderCompleted
                                           ]


require 'spree/preferable_decorator'

#Rails.application.config.after_initialize do #doing this here because we override the preferable class and are not eager loading it, maybe should be eager loaded??

 Spree::Config.configure do |config|
   config.allow_guest_checkout=true
   config.check_for_spree_alerts=false
   # config.currency='USD' # this is default now.
   config.default_country_id=49
   config.admin_interface_logo='logo_theline.svg'
   #config.default_meta_description='the line'
   #config.default_meta_keywords='the line'
   #config.default_seo_title=''
   #config.enable_mail_delivery=true
   #config.mail_bcc='retailops@elanstudio.com'
   # config.override_actionmailer_config=false
   #config.site_name=(ENV['SPREE_SITE_NAME'] || 'The Line')
   #config.site_url='www.theline.com'
 end

 Spree::Auth::Config.configure do |config|
  config.registration_step=true
 end

#monkey patching to use different keys on staging/preview for sandbox mode

unless ENV['BRAINTREE_PRIVATE_KEY'] && Settings.braintree.use_production_gateway
  Spree::PaymentMethod.class_eval do
    def preferences
      {
        :environment=>"sandbox", :merchant_id=>"kc3y3vv5kdmz8nrh", :merchant_account_id=>nil, :public_key=>"974bgnc83wt92skx", :private_key=>"27804117813c13ee16dd1fc3839259b5", :client_side_encryption_key=>"MIIBCgKCAQEAu0ESbIaGmaa9jn3J1Xc7JPdvZBa1TuCi9AmOCZwoOczlNNe6JqYfbFfEtLjUh36vM6Hizn/zvGMK8RTC6GB7zCpjTLdSHgFc3ki8QyPhx655+1kGOxwAhi76y9xT2KaPrKNiFLzvfYH8lA/v+8GVCiq15PgyNhtgDytHPnPHcdLVg4Ej4x1MGzgXOStapV/64q1X5a2Xl0c8+kH+kx8XfkBc7iVZBgugbMfpDx9EVbAk/vx+A/vFRkw7swZYBYOUQvZKl0DfmpmtOxhgTx6sZBehrz0MmahalbR2Ud8KXAbdvNluQhL8X2DBd6Z5bYyFbFMRgmzDy9YLara1PIs9sQIDAQAB", :server=>"test", :test_mode=>false
      }
    end

  end
end


#### TheLine Hack for getting strong params through to Spree Controllers ####
  # Users Controller for Account Info Update
    [:firstname, :lastname, :newsletter].each do |permitted_param|
      Spree::PermittedAttributes.user_attributes << permitted_param
    end

  # Checkout Controller for Gift Messages
      Spree::PermittedAttributes.checkout_attributes << {:gift_detail_attributes => [:from, :to, :message], :retail_staff_order_detail_attributes => [:customer_id, :trade_discount, :shipping_method, :internal_comments, :_destroy, :id]}
      Spree::PermittedAttributes.checkout_attributes << :luxury_packaging

  # Address Controller for Gift Messages
      Spree::PermittedAttributes.address_attributes << {:gift_detail_attributes => [:from, :to, :message], :retail_staff_order_detail_attributes => [:customer_id, :trade_discount, :shipping_method, :internal_comments, :_destroy, :id]}


 #Can't use the configure method for these because they are tied to db records using the Preferable class extensions
 ElanStudioPreferences::Store.instance.tap do |config|

  #BraintreeGateway with ID=1 is set to 'production' environment (and should be configured using heroku config vars)
#   config.set('spree/gateway/braintree_gateway/merchant_id/1', ENV['BRAINTREE_MERCHANT_ID'] || 'kc3y3vv5kdmz8nrh',:string)
#   config.set('spree/gateway/braintree_gateway/environment/1', ENV['BRAINTREE_ENVIRONMENT'] || 'sandbox',:string)
#   config.set('spree/gateway/braintree_gateway/private_key/1', ENV['BRAINTREE_PRIVATE_KEY'] || '27804117813c13ee16dd1fc3839259b5',:string)
#   config.set('spree/gateway/braintree_gateway/public_key/1', ENV['BRAINTREE_PUBLIC_KEY'] || '974bgnc83wt92skx',:string)
#   config.set('spree/gateway/braintree_gateway/client_side_encryption_key/1', ENV['BRAINTREE_CLIENT_SIDE_ENCRYPTION_KEY'] || 'MIIBCgKCAQEAu0ESbIaGmaa9jn3J1Xc7JPdvZBa1TuCi9AmOCZwoOczlNNe6JqYfbFfEtLjUh36vM6Hizn/zvGMK8RTC6GB7zCpjTLdSHgFc3ki8QyPhx655+1kGOxwAhi76y9xT2KaPrKNiFLzvfYH8lA/v+8GVCiq15PgyNhtgDytHPnPHcdLVg4Ej4x1MGzgXOStapV/64q1X5a2Xl0c8+kH+kx8XfkBc7iVZBgugbMfpDx9EVbAk/vx+A/vFRkw7swZYBYOUQvZKl0DfmpmtOxhgTx6sZBehrz0MmahalbR2Ud8KXAbdvNluQhL8X2DBd6Z5bYyFbFMRgmzDy9YLara1PIs9sQIDAQAB',:string)
#
#   #BraintreeGateway with ID=2 is set to 'development' environment (and is configured with Braintree Sandbox settings)
#   config.set('spree/gateway/braintree_gateway/merchant_id/2','kc3y3vv5kdmz8nrh',:string)
#   config.set('spree/gateway/braintree_gateway/environment/2','sandbox',:string)
#   config.set('spree/gateway/braintree_gateway/private_key/2','27804117813c13ee16dd1fc3839259b5',:string)
#   config.set('spree/gateway/braintree_gateway/public_key/2','974bgnc83wt92skx',:string)
#   config.set('spree/gateway/braintree_gateway/client_side_encryption_key/2','MIIBCgKCAQEAu0ESbIaGmaa9jn3J1Xc7JPdvZBa1TuCi9AmOCZwoOczlNNe6JqYfbFfEtLjUh36vM6Hizn/zvGMK8RTC6GB7zCpjTLdSHgFc3ki8QyPhx655+1kGOxwAhi76y9xT2KaPrKNiFLzvfYH8lA/v+8GVCiq15PgyNhtgDytHPnPHcdLVg4Ej4x1MGzgXOStapV/64q1X5a2Xl0c8+kH+kx8XfkBc7iVZBgugbMfpDx9EVbAk/vx+A/vFRkw7swZYBYOUQvZKl0DfmpmtOxhgTx6sZBehrz0MmahalbR2Ud8KXAbdvNluQhL8X2DBd6Z5bYyFbFMRgmzDy9YLara1PIs9sQIDAQAB',:string)

  config.set('spree/calculator/shipping/flat_rate/amount/1', 0.0, :decimal)
  config.set('spree/calculator/shipping/flat_rate/currency/1', 'USD', :string)

  config.set('spree/calculator/shipping/flat_rate/amount/2', 25.0, :decimal)
  config.set('spree/calculator/shipping/flat_rate/currency/2', 'USD', :string)

  config.set('spree/calculator/shipping/flat_rate/amount/4', 35.0, :decimal) #ShippingCalculator id 4 maps to 3 OY
  config.set('spree/calculator/shipping/flat_rate/currency/4', 'USD', :string)

  config.set('spree/calculator/shipping/flat_rate/amount/5', 45.0, :decimal) #5 maps to 4
  config.set('spree/calculator/shipping/flat_rate/currency/5', 'USD', :string)

  config.set('spree/calculator/shipping/flat_rate/amount/6', 50.0, :decimal) #6 to 5
  config.set('spree/calculator/shipping/flat_rate/currency/6', 'USD', :string)

  config.set('spree/calculator/shipping/flat_rate/amount/7', 0.0, :decimal) #7 to 6
  config.set('spree/calculator/shipping/flat_rate/currency/7', 'USD', :string)

  config.set('spree/calculator/shipping/flat_rate/amount/8', 0.0, :decimal) #8 to 7
  config.set('spree/calculator/shipping/flat_rate/currency/8', 'USD', :string)

 end
#end


#[#<Spree::ShippingMethod id: 1, name: "2nd-Day Free Shipping", display_on: "", deleted_at: nil, created_at: "2013-09-17 22:05:20", updated_at: "2014-03-11 20:48:47", tracking_url: "", admin_name: "">,
 #<Spree::ShippingMethod id: 2, name: "Next-Day Shipping", display_on: "", deleted_at: nil, created_at: "2013-09-17 22:05:29", updated_at: "2014-03-11 20:48:56", tracking_url: "", admin_name: "">,
 #<Spree::ShippingMethod id: 3, name: "International Rate", display_on: "", deleted_at: nil, created_at: "2014-03-27 18:49:58", updated_at: "2014-03-27 18:49:58", tracking_url: "", admin_name: "International Rate - Zone 1 ">,
 #<Spree::ShippingMethod id: 4, name: "International Rate", display_on: "", deleted_at: nil, created_at: "2014-03-27 18:51:05", updated_at: "2014-03-27 18:51:05", tracking_url: "", admin_name: "International Rate - Zone 2">,
 #<Spree::ShippingMethod id: 5, name: "International Rate", display_on: "", deleted_at: nil, created_at: "2014-03-27 18:52:41", updated_at: "2014-03-27 18:52:41", tracking_url: "", admin_name: "International Rate - Zone 3">,
 #<Spree::ShippingMethod id: 6, name: "Special Delivery TBD", display_on: "", deleted_at: nil, created_at: "2014-03-27 18:53:58", updated_at: "2014-03-27 18:53:58", tracking_url: "", admin_name: "Special Delivery">,
 #<Spree::ShippingMethod id: 7, name: "Ground 5-7 Business Days", display_on: "", deleted_at: nil, created_at: "2014-03-27 18:55:02", updated_at: "2014-03-27 18:55:02", tracking_url: "", admin_name: "Ground USA Only">]


#[#<Spree::Calculator::Shipping::FlatRate id: 1, type: "Spree::Calculator::Shipping::FlatRate", calculable_id: 1, calculable_type: "Spree::ShippingMethod", created_at: "2013-09-17 22:05:20", updated_at: "2013-09-17 22:05:20">,
 #<Spree::Calculator::Shipping::FlatRate id: 2, type: "Spree::Calculator::Shipping::FlatRate", calculable_id: 2, calculable_type: "Spree::ShippingMethod", created_at: "2013-09-17 22:05:29", updated_at: "2013-09-17 22:05:29">,
 #<Spree::Calculator::Shipping::FlatRate id: 4, type: "Spree::Calculator::Shipping::FlatRate", calculable_id: 3, calculable_type: "Spree::ShippingMethod", created_at: "2014-03-27 18:49:58", updated_at: "2014-03-27 18:49:58">,
 #<Spree::Calculator::Shipping::FlatRate id: 5, type: "Spree::Calculator::Shipping::FlatRate", calculable_id: 4, calculable_type: "Spree::ShippingMethod", created_at: "2014-03-27 18:51:05", updated_at: "2014-03-27 18:51:05">,
 #<Spree::Calculator::Shipping::FlatRate id: 6, type: "Spree::Calculator::Shipping::FlatRate", calculable_id: 5, calculable_type: "Spree::ShippingMethod", created_at: "2014-03-27 18:52:41", updated_at: "2014-03-27 18:52:41">,
 #<Spree::Calculator::Shipping::FlatRate id: 7, type: "Spree::Calculator::Shipping::FlatRate", calculable_id: 6, calculable_type: "Spree::ShippingMethod", created_at: "2014-03-27 18:53:58", updated_at: "2014-03-27 18:53:58">,
 #<Spree::Calculator::Shipping::FlatRate id: 8, type: "Spree::Calculator::Shipping::FlatRate", calculable_id: 7, calculable_type: "Spree::ShippingMethod", created_at: "2014-03-27 18:55:02", updated_at: "2014-03-27 18:55:02">]


#                              key                              |                                                                                                                                                                                  value
# --------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  spree/app_configuration/allow_guest_checkout                 | f
#  spree/app_configuration/allow_ssl_in_development_and_test    | f
#  spree/app_configuration/allow_ssl_in_production              | t
#  spree/app_configuration/allow_ssl_in_staging                 | t
#  spree/app_configuration/check_for_spree_alerts               | f
#  spree/app_configuration/currency                             | USD
#  spree/app_configuration/currency_decimal_mark                | .
#  spree/app_configuration/currency_symbol_position             | before
#  spree/app_configuration/currency_thousands_separator         | ,
#  spree/app_configuration/default_country_id                   | 49
#  spree/app_configuration/default_meta_description             | the line
#  spree/app_configuration/default_meta_keywords                | the line
#  spree/app_configuration/default_seo_title                    |
#  spree/app_configuration/display_currency                     | f
#  spree/app_configuration/enable_mail_delivery                 | t
#  spree/app_configuration/hide_cents                           | f
#  spree/app_configuration/mail_bcc                             | retailops@elanstudio.com
#  spree/app_configuration/mails_from                           | Elan Studio <hello@elanstudio.com>
#  spree/app_configuration/override_actionmailer_config         | f
#  spree/app_configuration/site_name                            | Elan Studio
#  spree/app_configuration/site_url                             | www.elanstudio.com
#  spree/auth_configuration/registration_step                   | t
#  spree/calculator/shipping/flat_rate/amount/1                 | 0.0
#  spree/calculator/shipping/flat_rate/amount/2                 | 25.0
#  spree/calculator/shipping/flat_rate/currency/1               | USD
#  spree/calculator/shipping/flat_rate/currency/2               | USD
#  spree/gateway/braintree_gateway/client_side_encryption_key/1 | MIIBCgKCAQEAraSdpOEhW/1QHyFBiJAkE9/o0k9hs9RPLT1HF+2YuCVvt5mJuV87bk56/FPP67B5DKFdFCSCKHQtnQF+kv1zpvS5mMTIrfEsnp6jI7lLuO7BPfB6y0hdO7/PlN3GNQsst7L+5PKINRMe+GCrEUhKQeeuIMK9aghyrSiQvlNEUG8Hj2c26P4Ow5BIbeMaHVZk/QbbMRHPAZP8epUPJXGcAfsRpgIsJbrs0dxr4mi8iqxFjTLVFDtJ9WubXoYjQHO1ZFRGULI2Y/z9XnWcBqVom7W4otxyf6vIiuMHjYrQ7GufThAv13otXnR7nswJ2UO7y0OO3w5PKWVgdg8E6jM/yQIDAQAB
#  spree/gateway/braintree_gateway/client_side_encryption_key/2 | MIIBCgKCAQEAu0ESbIaGmaa9jn3J1Xc7JPdvZBa1TuCi9AmOCZwoOczlNNe6JqYfbFfEtLjUh36vM6Hizn/zvGMK8RTC6GB7zCpjTLdSHgFc3ki8QyPhx655+1kGOxwAhi76y9xT2KaPrKNiFLzvfYH8lA/v+8GVCiq15PgyNhtgDytHPnPHcdLVg4Ej4x1MGzgXOStapV/64q1X5a2Xl0c8+kH+kx8XfkBc7iVZBgugbMfpDx9EVbAk/vx+A/vFRkw7swZYBYOUQvZKl0DfmpmtOxhgTx6sZBehrz0MmahalbR2Ud8KXAbdvNluQhL8X2DBd6Z5bYyFbFMRgmzDy9YLara1PIs9sQIDAQAB
#  spree/gateway/braintree_gateway/environment/1                | production
#  spree/gateway/braintree_gateway/environment/2                | sandbox
#  spree/gateway/braintree_gateway/merchant_id/1                | 5k7kkvh5bvxfsymf
#  spree/gateway/braintree_gateway/merchant_id/2                | kc3y3vv5kdmz8nrh
#  spree/gateway/braintree_gateway/private_key/1                | 7dcd7b8db8ecbfbf751977e1872c29a5
#  spree/gateway/braintree_gateway/private_key/2                | 27804117813c13ee16dd1fc3839259b5
#  spree/gateway/braintree_gateway/public_key/1                 | ykf3ystzj3j32b78
#  spree/gateway/braintree_gateway/public_key/2                 | 974bgnc83wt92skx




#Spree::Preferences::Store.instance.persistence=false


Spree.user_class = "Spree::User"

#puts 'in spree initializer'
#Spree::Config[:mails_from]='The Line <hello@elanstudio.com>' #why the fuck do these sometimes load the db and sometimes don't...

###MOVED THIS TO SEEDS BECAUSE IT LOADS THE DB EACH TIME AND IS STORED IN THE DB, SO ISN'T NEEDED HERE (unless someone changes in the admin, but those should stick anyway???)
#Spree::Auth::Config[:registration_step]=true
# Spree.config do |config|
#   # Example:
#   # Uncomment to override the default site name.
#   # config.site_name = "Spree Demo Site"
#   config.check_for_spree_alerts = false
#   config.enable_mail_delivery = true
#   config.override_actionmailer_config = false
# end

# Spree.config do |config|
#   config.allow_guest_checkout=false
# end

# Spree::Config.override_actionmailer_config = false

#:allow_guest_checkout=false
#<Spree::Preference id: 1, value: "49", key: "spree/app_configuration/default_country_id", value_type: "integer", created_at: "2013-09-11 22:25:04", updated_at: "2013-09-11 22:25:04">,
 #<Spree::Preference id: 30, value: "974bgnc83wt92skx", key: "spree/gateway/braintree_gateway/public_key/2", value_type: "string", created_at: "2013-09-23 19:09:43", updated_at: "2013-09-23 19:09:43">,
 #<Spree::Preference id: 31, value: "27804117813c13ee16dd1fc3839259b5", key: "spree/gateway/braintree_gateway/private_key/2", value_type: "string", created_at: "2013-09-23 19:10:12", updated_at: "2013-09-23 19:10:12">,
 #<Spree::Preference id: 32, value: "MIIBCgKCAQEAu0ESbIaGmaa9jn3J1Xc7JPdvZBa1TuCi9AmOCZw...", key: "spree/gateway/braintree_gateway/client_side_encrypt...", value_type: "text", created_at: "2013-09-23 19:11:36", updated_at: "2013-09-23 19:11:36">,
 #<Spree::Preference id: 5, value: "kc3y3vv5kdmz8nrh", key: "spree/gateway/braintree_gateway/merchant_id/1", value_type: "string", created_at: "2013-09-17 22:00:40", updated_at: "2013-09-17 22:00:40">,
 #<Spree::Preference id: 6, value: "974bgnc83wt92skx", key: "spree/gateway/braintree_gateway/public_key/1", value_type: "string", created_at: "2013-09-17 22:00:40", updated_at: "2013-09-17 22:00:40">,
 #<Spree::Preference id: 7, value: "27804117813c13ee16dd1fc3839259b5", key: "spree/gateway/braintree_gateway/private_key/1", value_type: "string", created_at: "2013-09-17 22:00:40", updated_at: "2013-09-17 22:00:40">,
 #<Spree::Preference id: 8, value: "MIIBCgKCAQEAu0ESbIaGmaa9jn3J1Xc7JPdvZBa1TuCi9AmOCZw...", key: "spree/gateway/braintree_gateway/client_side_encrypt...", value_type: "text", created_at: "2013-09-17 22:00:41", updated_at: "2013-09-17 22:00:41">,
 #<Spree::Preference id: 9, value: "sandbox", key: "spree/gateway/braintree_gateway/environment/1", value_type: "string", created_at: "2013-09-17 22:01:12", updated_at: "2013-09-17 22:01:12">,
 #<Spree::Preference id: 10, value: "0.0", key: "spree/calculator/shipping/flat_rate/amount/1", value_type: "decimal", created_at: "2013-09-17 22:05:20", updated_at: "2013-09-17 22:05:20">,
 #<Spree::Preference id: 11, value: "USD", key: "spree/calculator/shipping/flat_rate/currency/1", value_type: "string", created_at: "2013-09-17 22:05:20", updated_at: "2013-09-17 22:05:20">,
 #<Spree::Preference id: 12, value: "25.0", key: "spree/calculator/shipping/flat_rate/amount/2", value_type: "decimal", created_at: "2013-09-17 22:05:29", updated_at: "2013-09-17 22:05:29">,
 #<Spree::Preference id: 13, value: "USD", key: "spree/calculator/shipping/flat_rate/currency/2", value_type: "string", created_at: "2013-09-17 22:05:29", updated_at: "2013-09-17 22:05:29">,
 #<Spree::Preference id: 33, value: "The Line <hello@elanstudio.com>", key: "spree/app_configuration/mails_from", value_type: "string", created_at: "2013-09-24 14:58:10", updated_at: "2013-09-24 18:21:27">,
 #<Spree::Preference id: 3, value: "t", key: "spree/app_configuration/enable_mail_delivery", value_type: "boolean", created_at: "2013-09-12 22:03:51", updated_at: "2013-09-27 15:15:00">,
 #<Spree::Preference id: 34, value: "retailops@elanstudio.com", key: "spree/app_configuration/mail_bcc", value_type: "string", created_at: "2013-09-27 15:24:26", updated_at: "2013-09-27 15:24:26">,
 #<Spree::Preference id: 4, value: "f", key: "spree/app_configuration/override_actionmailer_confi...", value_type: "boolean", created_at: "2013-09-12 22:03:51", updated_at: "2013-09-27 15:25:08">,
 #<Spree::Preference id: 14, value: "t", key: "spree/auth_configuration/registration_step", value_type: "boolean", created_at: "2013-09-18 20:00:56", updated_at: "2013-09-18 20:00:56">,
 #<Spree::Preference id: 15, value: "The Line", key: "spree/app_configuration/site_name", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 16, value: "", key: "spree/app_configuration/default_seo_title", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 17, value: "the line", key: "spree/app_configuration/default_meta_keywords", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 18, value: "the line", key: "spree/app_configuration/default_meta_description", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 19, value: "www.theline.com", key: "spree/app_configuration/site_url", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 20, value: "t", key: "spree/app_configuration/allow_ssl_in_production", value_type: "boolean", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 21, value: "t", key: "spree/app_configuration/allow_ssl_in_staging", value_type: "boolean", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 22, value: "f", key: "spree/app_configuration/allow_ssl_in_development_an...", value_type: "boolean", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 2, value: "f", key: "spree/app_configuration/check_for_spree_alerts", value_type: "boolean", created_at: "2013-09-12 15:00:02", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 23, value: "f", key: "spree/app_configuration/display_currency", value_type: "boolean", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 24, value: "f", key: "spree/app_configuration/hide_cents", value_type: "boolean", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 25, value: "USD", key: "spree/app_configuration/currency", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 26, value: "before", key: "spree/app_configuration/currency_symbol_position", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 27, value: ".", key: "spree/app_configuration/currency_decimal_mark", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 28, value: ",", key: "spree/app_configuration/currency_thousands_separato...", value_type: "string", created_at: "2013-09-19 13:41:33", updated_at: "2013-09-19 13:41:33">,
 #<Spree::Preference id: 29, value: "kc3y3vv5kdmz8nrh", key: "spree/gateway/braintree_gateway/merchant_id/2", value_type: "string", created_at: "2013-09-23 19:09:05", updated_at: "2013-09-23 19:09:05">


#      preference :address_requires_state, :boolean, default: true # should state/state_name be required
#     preference :admin_interface_logo, :string, default: 'logo/spree_50.png'
#     preference :admin_products_per_page, :integer, default: 10
#     preference :allow_backorder_shipping, :boolean, default: false # should only be true if you don't need to track inventory
#     preference :allow_checkout_on_gateway_error, :boolean, default: false
#     preference :allow_guest_checkout, :boolean, default: true
#     preference :allow_ssl_in_development_and_test, :boolean, default: false
#     preference :allow_ssl_in_production, :boolean, default: true
#     preference :allow_ssl_in_staging, :boolean, default: true
#     preference :alternative_billing_phone, :boolean, default: false # Request extra phone for bill addr
#     preference :alternative_shipping_phone, :boolean, default: false # Request extra phone for ship addr
#     preference :always_include_confirm_step, :boolean, default: false # Ensures confirmation step is always in checkout_progress bar, but does not force a confirm step if your payment methods do not support it.
#     preference :always_put_site_name_in_title, :boolean, default: true
#     preference :auto_capture, :boolean, default: false # automatically capture the credit card (as opposed to just authorize and capture later)
#     preference :check_for_spree_alerts, :boolean, default: true
#     preference :checkout_zone, :string, default: nil # replace with the name of a zone if you would like to limit the countries
#     preference :company, :boolean, default: false # Request company field for billing and shipping addr
#     preference :currency, :string, default: "USD"
#     preference :currency_decimal_mark, :string, default: "."
#     preference :currency_symbol_position, :string, default: "before"
#     preference :currency_thousands_separator, :string, default: ","
#     preference :display_currency, :boolean, default: false
#     preference :default_country_id, :integer
#     preference :default_meta_description, :string, default: 'Spree demo site'
#     preference :default_meta_keywords, :string, default: 'spree, demo'
#     preference :default_seo_title, :string, default: ''
#     preference :dismissed_spree_alerts, :string, default: ''
#     preference :hide_cents, :boolean, default: false
#     preference :last_check_for_spree_alerts, :string, default: nil
#     preference :layout, :string, default: 'spree/layouts/spree_application'
#     preference :logo, :string, default: 'logo/spree_50.png'
#     preference :max_level_in_taxons_menu, :integer, default: 1 # maximum nesting level in taxons menu
#     preference :orders_per_page, :integer, default: 15
#     preference :prices_inc_tax, :boolean, default: false
#     preference :products_per_page, :integer, default: 12
#     preference :redirect_https_to_http, :boolean, :default => false
#     preference :require_master_price, :boolean, default: true
#     preference :shipment_inc_vat, :boolean, default: false
#     preference :shipping_instructions, :boolean, default: false # Request instructions/info for shipping
#     preference :show_only_complete_orders_by_default, :boolean, default: true
#     preference :show_variant_full_price, :boolean, default: false #Displays variant full price or difference with product price. Default false to be compatible with older behavior
#     preference :show_products_without_price, :boolean, default: false
#     preference :show_raw_product_description, :boolean, :default => false
#     preference :site_name, :string, default: 'Spree Demo Site'
#     preference :site_url, :string, default: 'demo.spreecommerce.com'
#     preference :tax_using_ship_address, :boolean, default: true
#     preference :track_inventory_levels, :boolean, default: true # Determines whether to track on_hand values for variants / products.
#
#     # Preferences related to image settings
#     preference :attachment_default_url, :string, default: '/spree/products/:id/:style/:basename.:extension'
#     preference :attachment_path, :string, default: ':rails_root/public/spree/products/:id/:style/:basename.:extension'
#     preference :attachment_url, :string, default: '/spree/products/:id/:style/:basename.:extension'
#     preference :attachment_styles, :string, default: "{\"mini\":\"48x48>\",\"small\":\"100x100>\",\"product\":\"240x240>\",\"large\":\"600x600>\"}"
#     preference :attachment_default_style, :string, default: 'product'
#     preference :s3_access_key, :string
#     preference :s3_bucket, :string
#     preference :s3_secret, :string
#     preference :s3_headers, :string, default: "{\"Cache-Control\":\"max-age=31557600\"}"
#     preference :use_s3, :boolean, default: false # Use S3 for images rather than the file system
#     preference :s3_protocol, :string
#     preference :s3_host_alias, :string
#
#     # Default mail headers settings
#     preference :enable_mail_delivery, :boolean, :default => false
#     preference :mails_from, :string, :default => 'spree@example.com'
#     preference :mail_bcc, :string, :default => 'spree@example.com'
#     preference :intercept_email, :string, :default => nil
#
#     # Default smtp settings
#     preference :override_actionmailer_config, :boolean, :default => true
#     preference :mail_host, :string, :default => 'localhost'
#     preference :mail_domain, :string, :default => 'localhost'
#     preference :mail_port, :integer, :default => 25
#     preference :secure_connection_type, :string, :default => Core::MailSettings::SECURE_CONNECTION_TYPES[0]
#     preference :mail_auth_type, :string, :default => Core::MailSettings::MAIL_AUTH[0]
#     preference :smtp_username, :string
#     preference :smtp_password, :string



# from: https://solidus.io/blog/2015/08/19/ransack-vulnerability.html
# This is a less complete solution than the new releases of Solidus and Spree,
# which also change searchable attributes to a whitelist.  It is designed to
# apply without issue to as many stores as possible (at least to Spree 2.1,
# 2.2, 2.3, 2.4, 3.0, and Solidus).
#
# Custom Ransack searches in your store may have to be added to this list.
Rails.application.config.to_prepare do
  raise "Spree.user_class must be defined first" unless Spree.user_class

  whitelisted_associations = {
    # Revoke the ability to search across associations via ransack
    ActiveRecord::Base => [],

    # Put back the ability to search across associations that we know are used
    Spree::LineItem => ['variant'],
    Spree::Order => ['shipments', 'user', 'promotions', 'bill_address', 'ship_address', 'line_items', 'inventory_units'],
    Spree::Product => ['stores', 'variants_including_master', 'master', 'variants'],
    Spree::Promotion => ['codes'],
    Spree::Variant => ['option_values', 'product', 'prices', 'default_price'],

    Spree.user_class => ['bill_address', 'ship_address']
  }

  whitelisted_associations.each do |klazz, associations|
    klazz.define_singleton_method(:ransackable_associations) { |auth_object=nil| associations }
  end
end

