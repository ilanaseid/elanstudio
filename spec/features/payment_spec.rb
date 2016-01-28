require 'spec_helper'
require 'rails_helper'

describe "Payment Processing", :type => :feature do
    before(:all) do
      FactoryGirl.create(:global_zone)
      FactoryGirl.create(:free_shipping_method)
    end

    before(:each) do
      unless Spree::PaymentMethod.exists?
        FactoryGirl.create(:braintree_sandbox_payment_method)
      end
      @preexisting_user = Spree::User.create(email: Faker::Internet.email, firstname: Faker::Name.first_name, lastname: Faker::Name.last_name, password: "qwerty1234", password_confirmation: "qwerty1234")
    end

  scenario "User can create a new credit card, checkout with a saved credit card, create a new card and use it, create a new card and switch cards to a saved card mid checkout", js: true do

    address = FactoryGirl.create(:address)

    product = create_and_verify_basic_product_macro
    products = []
    products << product

    # make sure not international:
    expect(address.country).to eq(product.stock_items.first.stock_location.country)
    # make sure not logged in
      check_not_logged_in_macro
    # create account
      signup_macro

    # add stuff
      # add a product to cart
      add_basic_product_to_cart_macro(product)
      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # checkout # 1 - new card (VISA 1111)
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro
      # successfully complete review and confirm, verifying products were bought
      expect(page).to have_content('Visa Ending in 1111')
      # card number matches
      complete_review_and_confirm_macro(products)
      expect(page).to have_content('Visa Ending in 1111')

    # checkout # 2 - with saved card 1 (VISA 1111)
      product2 = create_and_verify_basic_product_macro
      # add a product to cart
      add_basic_product_to_cart_macro(product2)
      # if not on the cart page, go there
      (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
      # click checkout to start address process
      all(:xpath, '//button[@id="checkout-link"]')[0].click
      #complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment 2
      # if not on the payment page, go to it
      (URI.parse(current_url).path == '/checkout/payment') ? nil : (visit '/checkout/payment')
      # fill in credit card info
      choose('use_existing_card_yes')
      # go to review and confirm
      click_button I18n.t('actions.save_and_continue_to_confirm')
      expect(page).to have_content('Visa Ending in 1111')
      # successfully complete review and confirm, verifying products were bought
      click_button I18n.t('spree.place_order') # Click place order
      # expect confirmation successful with correct card
      expect(page).to have_content(I18n.t('cart.thank_you')) # Thank you for your order
      expect(page).to have_content('Visa Ending in 1111')

    # checkout # 3 - checkout with new card 2 (MasterCard 4444) with existing Visa 1111 saved
      product3 = create_and_verify_basic_product_macro
      # add a product to cart
      add_basic_product_to_cart_macro(product3)
      # if not on the cart page, go there
      (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
      # click checkout to start address process
      all(:xpath, '//button[@id="checkout-link"]')[0].click
      #complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment 3
      # if not on the payment page, go to it
      (URI.parse(current_url).path == '/checkout/payment') ? nil : (visit '/checkout/payment')
      # fill in credit card info
      choose('use_existing_card_no')

      default_options = {
        card_number: "5555 5555 5555 4444",
        card_month: "5",
        card_year: "2021",
        card_code: "420"
      }

      page.fill_in "card_number", with: default_options[:card_number]
      page.select default_options[:card_month], from: "card_month"
      page.select default_options[:card_year], from: "card_year"
      page.fill_in "card_code", with: default_options[:card_code]

      # go to review and confirm
      click_button I18n.t('actions.save_and_continue_to_confirm')
      expect(page).to have_content('MasterCard Ending in 4444')
      # successfully complete review and confirm, verifying products were bought
      click_button I18n.t('spree.place_order') # Click place order
      # expect confirmation successful with correct card
      expect(page).to have_content(I18n.t('cart.thank_you')) # Thank you for your order
      expect(page).to have_content('MasterCard Ending in 4444')

    # checkout # 4 - two cards saved (MC and Visa), use saved card 2 (Visa 1111)
      product4 = create_and_verify_basic_product_macro
      # add a product to cart
      add_basic_product_to_cart_macro(product4)
      # if not on the cart page, go there
      (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
      # click checkout to start address process
      all(:xpath, '//button[@id="checkout-link"]')[0].click
      #complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment 3
      # if not on the payment page, go to it
      (URI.parse(current_url).path == '/checkout/payment') ? nil : (visit '/checkout/payment')
      # fill in credit card info
      choose('use_existing_card_yes')
      all(:xpath, '//input[@name="order[existing_card]"]')[1].click
      # go to review and confirm
      click_button I18n.t('actions.save_and_continue_to_confirm')
      expect(page).to have_content('Visa Ending in 1111')
      # successfully complete review and confirm, verifying products were bought
      click_button I18n.t('spree.place_order') # Click place order
      # expect confirmation successful with correct card
      expect(page).to have_content(I18n.t('cart.thank_you')) # Thank you for your order
      expect(page).to have_content('Visa Ending in 1111')

     # checkout # 5 - three cards created, use saved card 3 (Visa 1111)
      product5 = create_and_verify_basic_product_macro
      # add a product to cart
      add_basic_product_to_cart_macro(product5)
      # if not on the cart page, go there
      (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
      # click checkout to start address process
      all(:xpath, '//button[@id="checkout-link"]')[0].click
      #complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment 3
      # if not on the payment page, go to it
      (URI.parse(current_url).path == '/checkout/payment') ? nil : (visit '/checkout/payment')
      # fill in credit card info
      choose('use_existing_card_no')

      default_options2 = {
        card_number: "3714 496353 98431",
        card_month: "5",
        card_year: "2022",
        card_code: "4201"
      }

      page.fill_in "card_number", with: default_options2[:card_number]
      page.select default_options2[:card_month], from: "card_month"
      page.select default_options2[:card_year], from: "card_year"
      page.fill_in "card_code", with: default_options2[:card_code]
      # go to review and confirm
      click_button I18n.t('actions.save_and_continue_to_confirm')
      expect(page).to have_content('American Express Ending in 8431')
      click_button I18n.t('spree.place_order') # Click place order
      expect(page).to have_content('American Express Ending in 8431')

      # checkout # 6 - three cards created, use first created card (Visa 1111)
      product6 = create_and_verify_basic_product_macro
      # add a product to cart
      add_basic_product_to_cart_macro(product6)
      # if not on the cart page, go there
      (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
      # click checkout to start address process
      all(:xpath, '//button[@id="checkout-link"]')[0].click
      #complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment 3
      # if not on the payment page, go to it
      (URI.parse(current_url).path == '/checkout/payment') ? nil : (visit '/checkout/payment')
      # fill in credit card info
      choose('use_existing_card_yes')
      all(:xpath, '//input[@name="order[existing_card]"]')[2].click
      # go to review and confirm
      click_button I18n.t('actions.save_and_continue_to_confirm')
      expect(page).to have_content('Visa Ending in 1111')
      # successfully complete review and confirm, verifying products were bought
      click_button I18n.t('spree.place_order') # Click place order
      # expect confirmation successful with correct card
      expect(page).to have_content(I18n.t('cart.thank_you')) # Thank you for your order
      expect(page).to have_content('Visa Ending in 1111')
  end

  scenario "The correct (specific) processor declined message is displayed", js: true do
    # sign into preexisting account, add a product, checkout with amount that would trigger Fraud suspected
    product = create_and_verify_basic_product_macro(FactoryGirl.create(:product, price: 2014.00, cost_price: 2014.00))

    products = []
    products << product

    # login
      visit '/'
      login_macro

    # add stuff
      # add a product to cart
      add_basic_product_to_cart_macro(product)
      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # checkout and get error code
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro

      expect(URI.parse(current_url).path).to eq('/checkout/confirm')

      # place order
      click_button I18n.t('spree.place_order') # Click place order

      # Expect the correct Braintree Sandbox error handling
      expect(page).to have_content("We’re having trouble processing your payment information.")
      expect(page).to have_content("2014 Processor Declined - Fraud Suspected")
  end

  scenario "The correct non-specific processor declined message is diplayed", js: true do
    # sign into preexisting account, add a product, checkout with amount between $2063.00-$2999.99
    # Will trigger generic "processor delinced" messag

    product = create_and_verify_basic_product_macro(FactoryGirl.create(:product, price: 2090.00, cost_price: 2090.00))

    products = []
    products << product

    # login
      visit '/'
      login_macro

    # add stuff
      # add a product to cart
      add_basic_product_to_cart_macro(product)
      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # checkout and get error code
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro

      expect(URI.parse(current_url).path).to eq('/checkout/confirm')

      # place order
      click_button I18n.t('spree.place_order') # Click place order

      # Expect the correct Braintree Sandbox error handling
      expect(page).to have_content("We’re having trouble processing your payment information.")
      expect(page).to have_content("2090 Processor Declined")
  end

end
