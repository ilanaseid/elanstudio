require 'rails_helper'

def registration_macro
  visit spree.signup_path
  within('.main') do
    expect(page).to have_content(I18n.t('headings.register'))
    fill_in 'First Name', :with=>'Test'
    fill_in 'Last Name', :with=>'User'
    fill_in 'Email', :with=>'test+user@theline.com'
    fill_in 'Password', :with=>'password'

    click_button I18n.t('actions.create_account')
  end
end

def logout_macro
  visit spree.logout_path
  expect(page).to have_content("Signed out successfully.")
end

describe 'registration', :type => :feature do

  before(:each) do
    FactoryGirl.create(:stock_location, :default)
  end

  describe 'GET /signup and register', :js => true do
    it "should prevent registration without required fields" do
      visit spree.signup_path
      within('.main') do
        expect(page).to have_content(I18n.t('headings.register'))
        click_button I18n.t('actions.create_account')
        # note, this is testing with HTML5 validation, not javascript fallback
        expect(page).to have_selector(':invalid')
      end
      expect(current_path).to eq(spree.signup_path)
    end
    it "should allow a new user to register" do
      visit spree.signup_path
      within('.main') do
        expect(page).to have_content(I18n.t('headings.register'))
        fill_in 'First Name', :with=>'Test'
        fill_in 'Last Name', :with=>'User'
        fill_in 'Email', :with=>'test+user@example.com'
        fill_in 'Password', :with=>'password'

        click_button I18n.t('actions.create_account')
      end
      #sleep 45.seconds
      expect(current_path).to eq('/')
      within('#navWrap') do
        expect(page).to have_content('Test')
      end
    end
    it "should prevent registration if user already exists"  do
      # register
      registration_macro
      # logout
      logout_macro

      # try to register again
      registration_macro

      expect(current_path).to eq(spree.signup_path)
      expect(page).to have_content('has already been taken')
    end

  end

end
