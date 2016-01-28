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
    # flow: be anonymous > add stuff to cart > checkout as guest

    address = FactoryGirl.create(:address)

    product = create_and_verify_basic_product_macro
    products = []
    products << product

    # make sure not international:
    expect(address.country).to eq(product.stock_items.first.stock_location.country)

    # make sure not logged in
      check_not_logged_in_macro

    # add stuff
      # add a product to cart
      add_basic_product_to_cart_macro(product)
      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # checkout
      # select guest checkout, fill in address
      start_guest_checkout_macro
      # complete shipping
      complete_shipping_selection_macro
      # complete payment
      complete_payment_info_macro
      # successfully complete review and confirm, verifying products were bought
      complete_review_and_confirm_macro(products)
  end

end
