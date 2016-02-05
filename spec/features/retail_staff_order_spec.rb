require 'spec_helper'
require 'rails_helper'

### RETAIL STAFF ORDER ###
def retail_staff_login_with_product_in_cart
  address = FactoryGirl.create(:address)

  product = create_and_verify_basic_product_macro
  products = []
  products << product

  # make sure not international:
  expect(address.country).to eq(product.stock_items.first.stock_location.country)

  # make sure not logged in
  check_not_logged_in_macro

  # login as a retail staff user
  retail_staff_login_macro

  # add stuff
  # add a product to cart
  add_basic_product_to_cart_macro(product)
  # confirm stuff is in cart
  check_cart_for_product_macro(product)

  return products
end

def retail_staff_order_type_present?
  within(".main") do
    expect(page).to have_content(I18n.t('retail_order.staff_order_type'))
    expect(page).to have_content(I18n.t('retail_order.personal_order'))
    expect(page).to have_content(I18n.t('retail_order.apartment_order'))
  end
end

### REGISTERED (NON-RETAIL-STAFF) ORDER ###
def registed_user_login_with_product_in_cart
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
  return products
end

### NON-APARTMENT ORDER (Either not retail staff or retail staff personal order)###
def apartment_order_form_not_present?
  within(".main") do
    expect(page).not_to have_content(I18n.t('retail_order.staff_order_type'))
    expect(page).not_to have_content(I18n.t('retail_order.personal_order'))
    expect(page).not_to have_content(I18n.t('retail_order.apartment_order'))
    expect(page).not_to have_content(I18n.t('retail_order.customer_id'))
    expect(page).not_to have_content(I18n.t('retail_order.trade_discount'))
    expect(page).not_to have_content(I18n.t('retail_order.shipping_method'))
    expect(page).not_to have_content(I18n.t('retail_order.carry_out'))
    expect(page).not_to have_content(I18n.t('retail_order.messenger_service'))
    expect(page).not_to have_content(I18n.t('retail_order.pack_out'))
    expect(page).not_to have_content(I18n.t('retail_order.internal_comments'))
    expect(page).not_to have_content('apartment_customer@elanstudio.com')
    expect(page).not_to have_content('internal comments for a customer ordering from the apartment')
  end
end

#this is for non-retail staff users
def fill_in_address_non_apartment_order
  # if not on the cart page, go there
  (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
  # click checkout to start address process
  all(:xpath, '//button[@id="checkout-link"]')[0].click # "Checkout"
  #check for absence of apartment order form
  apartment_order_form_not_present?
  # fill in billing/contact info
  fill_in_billing_info_macro(FactoryGirl.create(:bill_address))
  #use same shipping as billing address
  check 'order_use_billing'
  # continue to shipping
  click_button I18n.t('actions.save_and_continue_to_delivery') # "Continue to Shipping"
end

#this is for retail staff but personal order
def fill_in_address_personal_order
  # if not on the cart page, go there
  (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
  # click checkout to start address process
  all(:xpath, '//button[@id="checkout-link"]')[0].click # "Checkout"
  #select personal order
  choose 'order_retail_staff_order_detail_attributes__destroy_1'
  # fill in billing/contact info
  fill_in_billing_info_macro(FactoryGirl.create(:bill_address))
  #use same shipping as billing address
  check 'order_use_billing'
  # continue to shipping
  click_button I18n.t('actions.save_and_continue_to_delivery') # "Continue to Shipping"
end

def review_and_confirm_non_apartment_order(products)
  # successfully complete review and confirm, verifying products were bought
  expect(URI.parse(current_url).path).to eq('/checkout/confirm')
  #check for absence of apartment order form
  apartment_order_form_not_present?
  # expect review and confirm to have every product
  check_page_for_all_products_macro(products)
  # place order
  click_button I18n.t('spree.place_order') # Click place order
end

def check_non_apartment_order_confirmation(products)
  # expect confirmation successful with every product
  expect(page).to have_content(I18n.t('cart.thank_you')) # Thank you for your order
  check_page_for_all_products_macro(products)
  #check for absence of apartment order form
  apartment_order_form_not_present?
  check_for_empty_minicart_text_macro # My Bag 0
end

### APARTMENT ORDER ###
def apartment_order_form_present?
  within(".main") do
    expect(page).to have_content(I18n.t('retail_order.customer_id'))
    expect(page).to have_content(I18n.t('retail_order.trade_discount'))
    expect(page).to have_content(I18n.t('retail_order.shipping_method'))
    expect(page).to have_content(I18n.t('retail_order.internal_comments'))
  end
end

def apartment_order_form_titles_present?
  within(".main") do
    expect(page).to have_content(I18n.t('headings.retail_staff_order_message'))
    expect(page).to have_content(I18n.t('retail_order.customer_id').upcase)
    expect(page).to have_content(I18n.t('retail_order.trade_discount').upcase)
    expect(page).to have_content(I18n.t('retail_order.shipping_method').upcase)
    expect(page).to have_content(I18n.t('retail_order.internal_comments').upcase)
  end
end

def fill_in_apartment_order_form
  #only shown on address form and not on review and confirm
  retail_staff_order_type_present?

  #check that the generic form exists
  apartment_order_form_present?

  #check form options not shown in review & confirm
  expect(page).to have_content(I18n.t('retail_order.carry_out'))
  expect(page).to have_content(I18n.t('retail_order.messenger_service'))
  expect(page).to have_content(I18n.t('retail_order.pack_out'))

  #select apartment order
  choose 'order_retail_staff_order_detail_attributes__destroy_0'

  #fill in apartment order form details
  #customer id, no trade discount, carry out packout, and internal comments filled in
  page.fill_in "order[retail_staff_order_detail_attributes][customer_id]", with: 'apartment_customer@elanstudio.com'
  choose 'order_retail_staff_order_detail_attributes_trade_discount_no'
  choose 'order_retail_staff_order_detail_attributes_shipping_method_carry_out'
  page.fill_in "order[retail_staff_order_detail_attributes][internal_comments]", with: 'internal comments for a customer ordering from the apartment'
end

def fill_in_address_apartment_order
  # if not on the cart page, go there
  (URI.parse(current_url).path == '/cart') ? nil : (visit '/cart')
  # click checkout to start address process
  all(:xpath, '//button[@id="checkout-link"]')[0].click # "Checkout"
  #fill-in retail staff form for apartment order
  fill_in_apartment_order_form
  # fill in billing/contact info
  fill_in_billing_info_macro(FactoryGirl.create(:bill_address))
  #use same shipping as billing address
  check 'order_use_billing'
  # continue to shipping
  click_button I18n.t('actions.save_and_continue_to_delivery') # "Continue to Shipping"
end

def check_apartment_order_form_contents
  apartment_order_form_titles_present?
  # need to check that apartment order form same as entries
  expect(page).to have_content('apartment_customer@elanstudio.com')
  expect(page).to have_content(I18n.t('retail_order.carry_out'))
  expect(page).to have_content('internal comments for a customer ordering from the apartment')
end

def review_and_confirm_apartment_order(products)
  # successfully complete review and confirm, verifying products were bought
  expect(URI.parse(current_url).path).to eq('/checkout/confirm')
  #verify retail form contents
  check_apartment_order_form_contents
  # expect review and confirm to have every product
  check_page_for_all_products_macro(products)
  # place order
  click_button I18n.t('spree.place_order') # Click place order
end

def check_apartment_order_confirmation(products)
  # expect confirmation successful with every product
  expect(page).to have_content(I18n.t('cart.thank_you')) # Thank you for your order
  check_page_for_all_products_macro(products)
  # check for presence of retail form
  check_apartment_order_form_contents
  check_for_empty_minicart_text_macro # My Bag 0
end

### TESTING ###

describe "RetailStaffOrderDetail", :type => :feature do
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

  describe "GET /checkout and retail staff user type", :js => true do
    it "should show apartment POS form if retail staff user and apartment order selected" do
      products = retail_staff_login_with_product_in_cart

      # checkout
      fill_in_address_apartment_order

      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro

      review_and_confirm_apartment_order(products)
      check_apartment_order_confirmation(products)
    end

    it "should not show apartment POS form if retail staff user personal order selected" do
      products = retail_staff_login_with_product_in_cart

      # checkout
      fill_in_address_personal_order

      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro

      review_and_confirm_non_apartment_order(products)
      check_non_apartment_order_confirmation(products)
    end

    #personal to apartment order
    it "should create apartment order POS fields if personal order is changed to apartment order" do
      products = retail_staff_login_with_product_in_cart

      # checkout
      fill_in_address_personal_order

      # complete shipping
      complete_shipping_selection_macro

      # complete payment
      complete_payment_info_macro

      # successfully complete review and confirm, verifying products were bought
      expect(URI.parse(current_url).path).to eq('/checkout/confirm')

      #check for absence of apartment order form
      apartment_order_form_not_present?

      # expect review and confirm to have every product
      check_page_for_all_products_macro(products)
      #steps are stopped at before order processed
      # go back to cart and change the order type
      fill_in_address_apartment_order

      # complete shipping
      complete_shipping_selection_macro

      # complete payment
      # choose('use_existing_card_no')
      complete_payment_info_macro

      review_and_confirm_apartment_order(products)
      check_apartment_order_confirmation(products)
    end

    #apartment to personal order
    it "should delete apartment order POS fields if apartment order is changed to personal order" do
      products = retail_staff_login_with_product_in_cart

      # checkout
      fill_in_address_apartment_order

      # complete shipping
      complete_shipping_selection_macro

      # complete payment
      complete_payment_info_macro

      # successfully complete review and confirm, verifying products were bought
      expect(URI.parse(current_url).path).to eq('/checkout/confirm')

      #check for presence of apartment order form
      check_apartment_order_form_contents

      # expect review and confirm to have every product
      check_page_for_all_products_macro(products)
      #steps are stopped at before order processed
      # go back to cart and change the order type
      fill_in_address_personal_order

      # complete shipping
      complete_shipping_selection_macro

        # complete payment
      # choose('use_existing_card_no')
      complete_payment_info_macro

      review_and_confirm_non_apartment_order(products)
      check_non_apartment_order_confirmation(products)
    end

    it "should not show apartment POS form if not retail staff user" do
      products = registed_user_login_with_product_in_cart

      # checkout
      #fill in address and check for absence of retail staff apartment order form
      fill_in_address_non_apartment_order

      # complete shipping
      complete_shipping_selection_macro

      # complete payment
      complete_payment_info_macro

      review_and_confirm_non_apartment_order(products)
      check_non_apartment_order_confirmation(products)
    end
  end
end
