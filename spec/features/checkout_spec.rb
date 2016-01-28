require 'spec_helper'
require 'rails_helper'

feature "Checking out and Cart Merging" do

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

  scenario "A newly created account can add and checkout", js: true do
    # flow: be anonymous > create account > add stuff > checkout

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

    # checkout
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro
      # successfully complete review and confirm, verifying products were bought
      complete_review_and_confirm_macro(products)
  end

  scenario "An anonymous cart can merge with a newly created account", js: true do
    # be anonymous > add stuff > create account > checkout with cart

    product = create_and_verify_product_with_options_macro
    products = []
    products << product

    # make sure not logged in
      check_not_logged_in_macro

    # add stuff
      # add a product to cart
      add_product_to_cart_macro(product)
      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # create account
      signup_macro

    # expect the cart still has the product from correctly merging
      check_cart_for_product_macro(product)

    # checkout
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro
      # successfully complete review and confirm, verifying products were bought
      complete_review_and_confirm_macro(products)
  end

  scenario "An anonymous cart can merge with an existing account", js: true  do
    # be anonymous > add stuff > login > checkout

    @preexisting_user = Spree::User.create(email: Faker::Internet.email, firstname: Faker::Name.first_name, lastname: Faker::Name.last_name, password: "qwerty1234", password_confirmation: "qwerty1234")

    product = create_and_verify_product_with_options_macro
    products = []
    products << product

    # be anonymous
      check_not_logged_in_macro

    # add stuff
      # add a product to cart
      add_product_to_cart_macro(product)

      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # login
      login_macro

    # make sure item is still in cart after merge
      check_cart_for_product_macro(product)

    # checkout
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro
      # successfully complete review and confirm, verifying products were bought
      complete_review_and_confirm_macro(products)
  end

  scenario "An existing account can add and checkout", js: true do
    # login > add stuff > checkout

    product = create_and_verify_product_with_options_macro
    products = []
    products << product

    # login
      visit '/'
      login_macro

    # add stuff
      # add a product to cart
      add_product_to_cart_macro(product)
      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # checkout
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro
      # successfully complete review and confirm, verifying products were bought
      complete_review_and_confirm_macro(products)
  end

  scenario "An existing account can add items to cart, logout, add to an anonymous cart, then login and merge the two", js: true do
    # login > add stuff > logout > add stuff > login > checkout
    #can merge cart from existing account, an anonymous cart, back to existing account

    products = []
    product_1 = create_and_verify_product_with_options_macro
    product_2 = create_and_verify_product_with_options_macro
    products << product_1
    products << product_2

    # login
      visit '/'
      login_macro

    # add stuff
      # add a product to cart
      add_product_to_cart_macro(product_1)
      # confirm stuff is in cart
      check_cart_for_product_macro(product_1)

    # logout
      logout_macro

    # add more stuff (anon)
      add_product_to_cart_macro(product_2)

    # log back in
      login_macro

    # make sure all products are in cart
      visit '/cart'
      check_page_for_all_products_macro(products)

     # checkout
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro
      # successfully complete review and confirm, verifying products were bought
      complete_review_and_confirm_macro(products)
  end

  scenario "A cart should be empty after logout", js: true do
    # login > add stuff > logout

    product = create_and_verify_product_with_options_macro
    products = []
    products << product

    # login
      visit '/'
      login_macro

    # add stuff
      # add a product to cart
      add_product_to_cart_macro(product)
      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # logout
      logout_macro

    # expect nothing in cart(s)
      check_for_empty_minicart_text_macro
      visit '/cart'
      expect(page).to have_content(I18n.t('spree.your_cart_is_empty')) # "Your bag is empty."
  end

  scenario "Can switch between accounts with proper cart merging", js: true do
    # login account 1 > add stuff > logout > add stuff > login account2 > checkout

    products = []
    product_1 = create_and_verify_product_with_options_macro
    product_2 = create_and_verify_product_with_options_macro
    products << product_1
    products << product_2

    @preexisting_user_2 = Spree::User.create(email: Faker::Internet.email, firstname: Faker::Name.first_name, lastname: Faker::Name.last_name, password: "qwerty1234", password_confirmation: "qwerty1234")

    # login account 1
      visit '/'
      login_macro

    # add stuff
      # add a product to cart
      add_product_to_cart_macro(product_1)
      # confirm stuff is in cart
      check_cart_for_product_macro(product_1)

    # logout
      logout_macro

    # expect nothing in cart(s)
      check_for_empty_minicart_text_macro
      visit '/cart'
      expect(page).to have_content(I18n.t('spree.your_cart_is_empty')) # "Your bag is empty."

    # login account 2
      login_macro(@preexisting_user_2)

    # add different stuff
      # add a different product to cart
      add_product_to_cart_macro(product_2)
      # confirm different product is in cart
      check_cart_for_product_macro(product_2)

    # expect first product not in cart
      visit '/cart'
      expect(page).to_not have_content("#{product_1.cms_product.title}")

    # checkout
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro
      # confirm
      expect(URI.parse(current_url).path).to eq('/checkout/confirm')
      # expect review and confirm to have only product 2 but not product 1
      expect(page).to have_content("#{product_2.cms_product.title}")
      expect(page).to_not have_content("#{product_1.cms_product.title}")
      #place order
      click_button I18n.t('spree.place_order') # Click place order
      # expect confirmation successful with only product 2
      expect(page).to have_content(I18n.t('cart.thank_you')) # Thank you for your order
      expect(page).to have_content("#{product_2.cms_product.title}")
      expect(page).to_not have_content("#{product_1.cms_product.title}")
      check_for_empty_minicart_text_macro
  end

  # scenario "The correct error message is displayed for CVV codes", js: true do
  #   # sign into preexisting account, add a product, checkout with incorrect CVV code


  #   product = create_and_verify_basic_product_macro(FactoryGirl.create(:product)

  #   products = []
  #   products << product

  #   # login
  #     visit '/'
  #     login_macro

  #   # add stuff
  #     # add a product to cart
  #     add_basic_product_to_cart_macro(product)
  #     # confirm stuff is in cart
  #     check_cart_for_product_macro(product)

  #   # checkout and get error code
  #     # complete address
  #     complete_address_info_macro
  #     # complete shipping
  #     complete_shipping_selection_macro
  #     # complete payment

  #     # if not on the payment page, go to it
  #     (URI.parse(current_url).path == '/checkout/payment') ? nil : (visit '/checkout/payment')

  #     # fill in credit card info
  #     fill_in_card_info_macro(card_code: 200)
  #     # fill_in_card_info_macro(card_code: "301")
  #     # fill_in_card_info_macro(card_code: "")

  #     # go to review and confirm
  #     click_button I18n.t('actions.save_and_continue_to_confirm') # "Continue to Review & Confirm"

  #     # expect(URI.parse(current_url).path).to eq('/checkout/confirm')
  #     # place order
  #     click_button I18n.t('spree.place_order') # Click place order

  #     sleep 10
  #     # Expect the correct Braintree Sandbox error handling
  #     # This is not currently working for CVV codes?
  #     # expect(page).to have_content("We’re having trouble processing your payment information.")
  # end

end
