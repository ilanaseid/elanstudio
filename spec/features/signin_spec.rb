require 'rails_helper'

describe 'signin', :type => :feature do
  describe '/login', :js => true do
    it "should say account not found if email doesn't exist" do
      visit spree.login_path
      click_button 'Close (Esc)'
      within('.main') do
        expect(page).to have_content('Log-in')
        fill_in 'Email', :with=>'blahblah@blah.com'
        fill_in 'Password', :with=>'blahblah'
        click_button 'Log-in'
      end
      expect(page).to have_content(I18n.t('devise.failure.not_found_in_database'))
    end
  end
end
