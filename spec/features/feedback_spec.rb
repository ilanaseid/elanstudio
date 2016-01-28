require 'rails_helper'

describe 'feedback', :type => :feature do
  describe 'GET / and submit feedback', :js => true do
    it "should display Feedback modal and form handling" do
      visit '/s/about'
      click_link I18n.t('site.nav.feedback')

      #sleep 1.seconds
      within('.lb-wrap') do
        expect(page).to have_content(I18n.t('site.nav.feedback'))
        fill_in 'Email', :with=>'test@example.com'
        fill_in 'Comment', :with=>'This is a test feedback comment from automated testing'
        click_button 'Submit'
      end
      #sleep 1.seconds
      within('.lb-wrap') do
        expect(page).to have_content('Thank You')
        click_button '×'
      end
      #sleep 2.seconds
      expect(page).not_to have_css('.lb-wrap')
    end

  end

end
