require 'spec_helper'
require 'rails_helper'


# These specs should reflect what is on the User Role Permissions doc, and vice versa, when there are changes.
# https://docs.google.com/a/theline.com/spreadsheets/d/17jsTXlu38tI53tlvqcuUwegUcObwhdrHb6NnnD59YN0/edit?usp=sharing
# some of these are already tested in retail_staff_order_spec, security_basic_spec etc.

feature "Superuser UI" do

  before :each do
     FactoryGirl.create(:stock_location, :default) if !Spree::StockLocation.default
  end

  scenario "superuser UI does not appear for regular users", js: true do
    # be a regular registered user
    @user = FactoryGirl.create(:spree_user)
    visit '/'
    login_macro(@user)

    # go to a product page
    visit FactoryGirl.create(:product).cms_product.friendly_path

    # don't see ui
    superuser_ui_classes.each do |superuser_ui_class|
      expect(page).to_not have_selector(superuser_ui_class)
    end
  end

  scenario "superuser UI does not appear for not-logged-in users", js: true do
    # be not logged in
    check_not_logged_in_macro
    # go to a product page
    visit FactoryGirl.create(:product).cms_product.friendly_path
    # don't see ui
    superuser_ui_classes.each do |superuser_ui_class|
      expect(page).to_not have_selector(superuser_ui_class)
    end
  end

  scenario "superuser UI does appear for a user with the role of staff", js: true do
    # be a staff user with superuser view on
    @user = FactoryGirl.create(:spree_staff_user)
    visit '/'
    login_macro(@user)

    # go to a product page
    visit FactoryGirl.create(:product).cms_product.friendly_path

    # see the ui
    superuser_ui_classes.each do |superuser_ui_class|
      expect(page).to have_selector(superuser_ui_class)
    end
  end

  scenario "superuser UI can be turned off for staff", js: true do
    # be a staff user with superuser view on
    @user = FactoryGirl.create(:spree_staff_user)
    visit '/'
    login_macro(@user)

    # go to staff settings
    visit '/account'
    expect(page).to have_no_content(/staff settings/i)

    # disable the view
    within('.contact-info-container') do
      click_link('Edit')
      expect(page).to have_content(/staff settings/i)
      find("input[name='user[disable_staff_inventory_ui]']").set(true)
      page.fill_in "user_current_password", with: 'qwerty1234'
      click_button "Update"
    end

    # go to a product page
    visit FactoryGirl.create(:product).cms_product.friendly_path

    # don't see ui
    superuser_ui_classes.each do |superuser_ui_class|
      expect(page).to_not have_selector(superuser_ui_class)
    end

  end

end

feature "Staff Settings" do

  before :each do
     FactoryGirl.create(:stock_location, :default) if !Spree::StockLocation.default
  end

  scenario "staff settings do not show up for regular users", js: true do
    # be a regular registered user
    @user = FactoryGirl.create(:spree_user)
    visit '/'
    login_macro(@user)

    # go to account management
    visit '/account'

    # don't see the staff settings
    expect(page).to have_no_content(/staff settings/i)
    within('.contact-info-container') do
      click_link('Edit')
      expect(page).to have_no_content(/staff settings/i)
    end
  end

  scenario "staff settings show up for staff user role", js: true do
    # be a staff user
    @user = FactoryGirl.create(:spree_staff_user)
    visit '/'
    login_macro(@user)

    # go to account management
    visit '/account'

    # see the staff settings
    within('.contact-info-container') do
      click_link('Edit')
      expect(page).to have_content(/staff settings/i)
    end
  end

end

feature "Checkout UI" do

  before :each do
    FactoryGirl.create(:stock_location, :default) if !Spree::StockLocation.default
    unless Spree::PaymentMethod.exists?
        FactoryGirl.create(:braintree_sandbox_payment_method)
    end
  end

  scenario "Apartment employees (staff_retail) and Customer Service (staff_customer service) do not remember cards", js: true do
    # login > add stuff > checkout
    product = create_and_verify_product_with_options_macro
    products = []
    products << product

    @user = FactoryGirl.create(:spree_staff_user, :with_stored_card)
    expect(@user.payment_sources.length).to be > 0

    # login
      visit '/'
      login_macro(@user)

    # add stuff
      # add a product to cart
      add_product_to_cart_macro(product)
      # confirm stuff is in cart
      check_cart_for_product_macro(product)

    # start checkout
      # complete address
      complete_address_info_macro
      # complete shipping
      complete_shipping_selection_macro

    # make sure payment page has right options for saved cards depending on user class

      # be on the payment page
      expect(URI.parse(current_url).path).to eq('/checkout/payment')

      # expect recently used cards is showing up for regular staff user
      expect(page).to have_content("Select a recently used card")
      expect(page).to have_content("Use a new card")

      # change the user class to staff retail
      @user.spree_roles.clear
      @user.spree_roles << Spree::Role.find_or_create_by(name: 'staff')
      @user.spree_roles << Spree::Role.find_or_create_by(name: 'retail')
      @user.save!

      # expect staff retail doesn't have the remembered cards option
      visit('/checkout/payment')
      expect(page).to have_no_content("Select a recently used card")
      expect(page).to have_no_content("Use a new card")

      # change the user class to staff customer service
      # change the user class to staff retail
      @user.spree_roles.clear
      @user.spree_roles << Spree::Role.find_or_create_by(name: 'staff')
      @user.spree_roles << Spree::Role.find_or_create_by(name: 'customer_service')
      @user.save!

      # expect staff customer service doesn't have the remembered cards option
      visit('/checkout/payment')
      expect(page).to have_no_content("Select a recently used card")
      expect(page).to have_no_content("Use a new card")
  end

end
