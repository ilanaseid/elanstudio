# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#Clear previous data
# Spree::Product.delete_all
# Spree::Variant.delete_all
# Spree::StockItem.delete_all
# Spree::Order.delete_all


Spree.config do |config|
  # Example:
  # Uncomment to override the default site name.
  # config.site_name = "Spree Demo Site"
  config.check_for_spree_alerts = false
  #config.enable_mail_delivery = true
  #config.override_actionmailer_config = false
end


Spree::Auth::Config.preferred_registration_step=true


#Setup Spree core/samples first
Spree::Core::Engine.load_seed if defined?(Spree::Core)


require Rails.root.join('db/spree_data')