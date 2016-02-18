# Configure Solidus Preferences
# See http://docs.solidus.io/Spree/AppConfiguration.html for details


require 'spree/preferable_decorator'

#### Hack for getting strong params through to Spree Controllers ####
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

Spree.config do |config|
  # Without this preferences are loaded and persisted to the database. This
  # changes them to be stored in memory.
  # This will be the default in a future version.
  config.use_static_preferences!

  # Core:
  config.default_country_id=49
  config.allow_guest_checkout=true
  config.admin_interface_logo='logo_elanstudio.svg'
  # Default currency for new sites
  config.currency = "USD"

  # from address for transactional emails
  config.mails_from = "store@example.com"

  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false

  # When set, product caches are only invalidated when they fall below or rise
  # above the inventory_cache_threshold that is set. Default is to invalidate cache on
  # any inventory changes.
  # config.inventory_cache_threshold = 3


  # Frontend:

  # Custom logo for the frontend
  # config.logo = "logo/solidus_logo.png"

  # Template to use when rendering layout
  # config.layout = "spree/layouts/spree_application"


  # Admin:

  # Custom logo for the admin
  # config.admin_interface_logo = "logo/solidus_logo.png"

  # Gateway credentials can be configured statically here and referenced from
  # the admin. They can also be fully configured from the admin.
  #
  # config.static_model_preferences.add(
  #   Spree::Gateway::StripeGateway,
  #   'stripe_env_credentials',
  #   secret_key: ENV['STRIPE_SECRET_KEY'],
  #   publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  #   server: Rails.env.production? ? 'production' : 'test',
  #   test_mode: !Rails.env.production?
  # )
end

#monkey patching to use different keys on staging/preview for sandbox mode
unless ENV['BRAINTREE_PRIVATE_KEY'] && Settings.braintree.use_production_gateway
  Spree::PaymentMethod.class_eval do
    def preferences
      {
        :environment=>"sandbox", :merchant_id=>"x8qs3hnwp2gvqcs7", :merchant_account_id=>nil, :public_key=>"4cwkj9bjrgf9crw8", :private_key=>"9577074424f696d7bf38b0347c183eb9", :client_side_encryption_key=>"MIIBCgKCAQEA60/whTi2sweWAAnjKnMAf7BlrdqqDAq2GcdpNr02YiFV3GvR6DpN4XuwDJ5MvDlGO3zszhwE/F0eitsPE7wfFAKQ0hHjx4/RUGYGSgoBnd3JLYuJ8yBAARNcxErlrisxLDewEGjm3s+oo6ofgIYeBZa1JWt+COhT4FlXaXvJ6sccOI0Bauqkit8dKbPXVyTHpjBpvgL8lSyLF4pV6qwowRK4Bo3w1JDFY6RwMl29j1sXKDJoLMRneBMAFkhlnm+kl6zSx6/cZ0B52EBlXtT++lwlNsZio9emXGzDPC0QfSJp1DND/FwePzwTGp0js963ZcnMfKz+7JHceyrXNz75cwIDAQAB", :server=>"test", :test_mode=>false
      }
    end
  end
end

# Spree::Auth::Config.configure do |config|
#   config.registration_step=true
# end


Spree::Frontend::Config.configure do |config|
  config.use_static_preferences!

  config.locale = 'en'
end

Spree::Backend::Config.configure do |config|
  config.use_static_preferences!

  config.locale = 'en'
end

Spree::Api::Config.configure do |config|
  config.use_static_preferences!

  config.requires_authentication = true
end

Spree.user_class = "Spree::User"
