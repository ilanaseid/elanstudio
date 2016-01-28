require 'rails_helper'

describe "AddToWishlist", :type => :feature do
  describe "GET /shop and add to wishlist", :js => true do

    before(:each) do
      @product = FactoryGirl.create(:product_with_option_types)
      @preexisting_user = FactoryGirl.create(:preexisting_user)
    end

    it "should show items added to wishlist on wilist page" do
      visit '/login' #spree.login_path
      click_button 'Close (Esc)'
      within('.main') do
        fill_in "spree_user[email]", with: @preexisting_user.email
        fill_in "spree_user[password]", with: "qwerty1234"
        click_button "Log-in"
      end

      visit @product.cms_product.friendly_path
      # activate wishlist dialog

        expect(page).to have_content(I18n.t('actions.save_wishlist_item').upcase)
        # click add button
        page.find(:css, '.btn-save').click
      within('.lb-wrap') do
        # interact with dialog and submit
        find('label', text: @product.variants.first.option_values.first.presentation).click
        click_button 'Submit'
        expect(page).to have_content('This item has been added to your wish list')
      end
      visit '/wishlist_items'
      within('.main') do
        expect(page).not_to have_content('You have no items in your wish list')
        expect(page).to have_content("#{@product.cms_product.title}")
      end
    end
  end
end
