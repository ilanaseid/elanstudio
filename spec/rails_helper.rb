ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

# Global testing macros

def add_basic_product_to_cart_macro(product)
  # Adds a product to the cart from its Product Detail Page, no size selections
  visit product.cms_product.friendly_path

  click_button I18n.t('actions.add_to_cart') # "Add to Bag"
  within('#navWrap') do # Click "My Bag" in the top nav
    click_link I18n.t('site.nav.cart')
  end
  within('#cartWrap') do
    within(".miniCart") do
      # expect(page).to have_content("JUST ADDED") # hard coded into Line.Cart.js
      expect(page).to have_content("#{product.cms_product.title}")
    end
  end
end

def add_product_to_cart_macro(product)
  # Adds a product to the cart from its Product Detail Page by variant ID
  visit product.cms_product.friendly_path
  find('label', text: product.variants.first.option_values.first.presentation).click
  click_button I18n.t('actions.add_to_cart') # "Add to Bag"
  within('#navWrap') do # Click "My Bag" in the top nav
    click_link I18n.t('site.nav.cart')
  end
  within('#cartWrap') do
    within(".miniCart") do
      # expect(page).to have_content("JUST ADDED") # hard coded into Line.Cart.js
      expect(page).to have_content("#{product.cms_product.title}")
    end
  end
end

def cart_not_empty_macro
  # Makes sure cart is not empty
  visit '/cart'
  expect(page).to_not have_content(I18n.t('spree.your_cart_is_empty'))
end

def check_cart_for_product_macro(product)
  # Makes sure a product is in the cart
  # if not on the cart page, go there
  (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')

  expect(page).to_not have_content(I18n.t('spree.your_cart_is_empty')) # "Your bag is empty"
  within(".cartItemList") do
    expect(page).to have_content(product.cms_product.title)
  end
end

def check_for_empty_minicart_text_macro
  # cursory check for "My Bag" to be 0 on any page
  expect(page).to have_content("#{I18n.t('site.nav.cart')} 0") #My Bag (0)
end

def check_not_logged_in_macro
  # Checks to make sure user is logged out.
  visit root_path
  expect(find('#navWrap')).to have_content(I18n.t('site.nav.login'))
  expect(page).to_not have_content(I18n.t('site.nav.logout'))
end

def check_page_for_all_products_macro(products)
  products.each do |product|
    check_page_for_product_macro(product)
  end
end

def check_page_for_product_macro(product)
  expect(page).to have_content("#{product.cms_product.title}")
end

def complete_address_info_macro
  # successfully completes entire address stage

  # if not on the cart page, go there
  (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
  # click checkout to start address process
  all(:xpath, '//button[@id="checkout-link"]')[0].click
  # fill in billing/contact info
  fill_in_billing_info_macro(FactoryGirl.create(:bill_address))
  #use same shipping as billing address
  check 'order_use_billing'
  # continue to shipping
  click_button I18n.t('actions.save_and_continue_to_delivery') # "Continue to Shipping"
end

def complete_payment_info_macro
  # successfully completes payment info stage with valid cc

  # if not on the payment page, go to it
  (URI.parse(current_url).path == '/checkout/payment') ? nil : (visit '/checkout/payment')

  # fill in credit card info
  fill_in_card_info_macro
  # go to review and confirm
  click_button I18n.t('actions.save_and_continue_to_confirm') # "Continue to Review & Confirm"
end

def complete_review_and_confirm_macro(products)
  # successfully completes review and confirm stages, verifies products at the end

  expect(URI.parse(current_url).path).to eq('/checkout/confirm')

  # expect review and confirm to have every product
  check_page_for_all_products_macro(products)
  # place order
  click_button I18n.t('spree.place_order') # Click place order
  # expect confirmation successful with every product
  expect(page).to have_content(I18n.t('cart.thank_you')) # Thank you for your order
  check_page_for_all_products_macro(products)
  check_for_empty_minicart_text_macro # My Bag 0
end

def complete_shipping_selection_macro
  # Make sure we can select a shipping method
  within('.shipping-method') do
    choose('order[shipments_attributes][0][selected_shipping_rate_id]')
  end
  # continue to payment
  click_button I18n.t('actions.save_and_continue_to_payment') # Continue to Payment"
end

def create_and_verify_basic_product_macro(product=FactoryGirl.create(:product))
  # Creates a product with no option types, just a master variant with 1 in stock.

  expect(product.variants.length).to eq(0)
  expect(product.master.total_on_hand).to eq(1)
  expect(product.master.in_stock?).to be(true)
  return product
end

def create_and_verify_product_with_options_macro(product=FactoryGirl.create(:product_with_option_types))
  # Default creates a product with two option types: Small and Medium.  Medium is not in stock.  The master variant is not in stock.

  # Make sure the first variant is in stock, 2nd is out of stock, master is out of stock
  expect(product.variants.first.in_stock?).to eq(true)
  expect(product.variants.last.in_stock?).to eq(false)
  expect(product.master.total_on_hand).to eq(0)
  expect(product.total_on_hand).to eq(1)
  return product
end

def email_signup_macro(first_name="Bob", last_name="Johnson", email="bob@aol.com")
  visit '/'
  within('#footer1') do
    expect(page).to have_content(I18n.t('headings.newsletter_receive_info').upcase)
    fill_in I18n.t('fields.email').downcase, :with=>email
    click_button I18n.t('actions.newsletter_add')
    expect(page).to have_content('Thank You')
  end
  expect(EmailSubscriber.find_by(email: email).email).to eq(email)
end

def fill_in_card_info_macro(options = {})
  # Will default to working card unless options are passed
  default_options = {
    card_number: "4111 1111 1111 1111",
    card_month: "4",
    card_year: "2020",
    card_code: "420"
  }
  options = default_options.merge(options)

  page.fill_in "card_number", with: options[:card_number]
  page.select options[:card_month], from: "card_month"
  page.select options[:card_year], from: "card_year"
  page.fill_in "card_code", with: options[:card_code]
end

def fill_in_billing_info_macro(address)
  page.fill_in "order[bill_address_attributes][firstname]", with: address.firstname
  page.fill_in "order[bill_address_attributes][lastname]", with: address.lastname
  page.fill_in "order[bill_address_attributes][address1]", with: address.address1
  page.fill_in "order[bill_address_attributes][address2]", with: address.address2
  page.fill_in "order[bill_address_attributes][city]", with: address.city
  page.fill_in "order[bill_address_attributes][zipcode]", with: address.zipcode

  # TODO: Use the Spree::State default file, so can test for NY / non-NY taxes
  find('#order_bill_address_attributes_state_id').find(:xpath, 'option[2]').select_option
  page.fill_in "order[bill_address_attributes][phone]", with: address.phone
end

def login_macro(account=@preexisting_user)
  within('#navWrap') do # login via nav
    click_link(I18n.t('site.nav.login'))
  end
  fill_in "spree_user[email]", with: account.email
  fill_in "spree_user[password]", with: "qwerty1234"
  click_button "Log-in"
  expect(find('#navWrap')).to have_content(account.firstname)
end

def logout_macro
  visit '/logout'
  within('.nb-wrap') do
    expect(page).to have_content("Signed out successfully.")
  end
end

def signup_macro(options={})
  default_options = {first_name: "Bob", last_name: "Johnson", email: "bob@aol.com", password: "qwerty1234"}
  options = options.reverse_merge default_options
  visit spree.signup_path
  within('.main') do
    expect(page).to have_content(I18n.t('headings.register'))
    fill_in 'First Name', :with=>options[:first_name]
    fill_in 'Last Name', :with=>options[:last_name]
    fill_in 'Email', :with=>options[:email]
    fill_in 'Password', :with=>options[:password]

    click_button I18n.t('actions.create_account')
  end
  expect(current_path).to eq('/')
  expect(find('#navWrap')).to have_content(options[:first_name])
end

# def signup_without_newsletter_macro(options={})
# deprecated now that we are opting everyone in.
#   default_options = {first_name: "Bob", last_name: "Johnson", email: "bob@aol.com", password: "qwerty1234"}
#   options = options.reverse_merge default_options
#   visit spree.signup_path
#   within('.main') do
#     expect(page).to have_content(I18n.t('headings.register'))
#     fill_in 'First Name', :with=>options[:first_name]
#     fill_in 'Last Name', :with=>options[:last_name]
#     fill_in 'Email', :with=>options[:email]
#     fill_in 'Password', :with=>options[:password]
#     page.uncheck('spree_user[newsletter]')
#     click_button I18n.t('actions.create_account')
#   end
#   expect(current_path).to eq('/')

#   expect(find('#navWrap')).to have_content(options[:first_name])

# end

def start_guest_checkout_macro
  # if not on the cart page, go there
  (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
  # click "checkout"
  click_button('checkout-link')
  # expect to be on the registration page
  expect(current_path).to eq('/checkout/registration')
  # expect that guest checkout is on
  expect(page).to have_content(Spree.t(:guest_checkout))
  # fill in the guest checkout email and click continue
  fill_in "order[email]", with: Faker::Internet.email
  # click continue and go to  address page.
  click_button("Continue")
  # fill in address stuff
  fill_in_billing_info_macro(FactoryGirl.create(:bill_address))
  #use same shipping as billing address
  check 'order_use_billing'
  # continue to shipping
  click_button I18n.t('actions.save_and_continue_to_delivery') # "Continue to Shipping"
end

def retail_staff_login_macro
  retail_user = FactoryGirl.create(:spree_retail_user)
  visit spree.login_path
  click_button 'Close (Esc)'
  within('.main') do
    fill_in "spree_user[email]", with: retail_user.email
    fill_in "spree_user[password]", with: retail_user.password
    click_button "Log-in"
  end

  # expect(find('#navWrap')).to have_content(retail_user.firstname)
  # expect(current_path).to eq('/')
end

def superuser_ui_classes
  return ['.has_superuser_ui', '.pos-inventory', '.pos-price', '.pos-available, .pos-sold-out, .pos-avail-other']
end

# end macros and helpers

Capybara.default_wait_time=5

DatabaseCleaner.strategy = :truncation

# then, whenever you need to clean the DB
DatabaseCleaner.clean

# clean cms content
ClearCMS::Content.delete_all

spree_spec = Gem::Specification.find_all_by_name('spree_core').first
%w(roles countries states zones stores).each do |filename|
  require File.join(spree_spec.gem_dir, "db/default/spree/#{filename}.rb")
end
require Rails.root.join('db/spree_data')
require Rails.root.join('db/dummy_data')

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end
