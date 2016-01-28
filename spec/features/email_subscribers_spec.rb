require 'rails_helper'

describe "EmailSubscribers", :type => :feature do

  before(:each) do
    FactoryGirl.create(:stock_location, :default)
  end

  describe "GET / and signup", :js => true do

    it "should show an email signup form" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      EmailSubscriber.delete_all

      visit '/'
      within('#footer1') do
        expect(page).to have_content(I18n.t('headings.newsletter_receive_info').upcase)

        fill_in 'email_subscriber[email]', :with=>'test@theline.com'
        click_button I18n.t('actions.newsletter_add')
        expect(page).to have_content('Thank You')
      end

      expect(EmailSubscriber.count).to eq(1)
    end

    it "should store the utm_source and utm_medium params" do
      EmailSubscriber.delete_all

      visit '/?utm_source=source&utm_medium=medium'
      visit '/'
      within('#footer1') do
        expect(page).to have_content(I18n.t('headings.newsletter_receive_info').upcase)
        fill_in 'email_subscriber[email]', :with=>'test@theline.com'
        click_button I18n.t('actions.newsletter_add')
        expect(page).to have_content('Thank You')
      end
      expect(EmailSubscriber.count).to eq(1)
      email=EmailSubscriber.last
      expect(email.utm_source).to eq('source')
      expect(email.utm_medium).to eq('medium')

    end

  end

  # describe "Checking for previous email subscriptions", :js => true do
  ## deprecrated now that we are opting everyone in
  #   it "makes sure a new account with a previous subscription stays subscribed even if they uncheck the box" do
  #     email = "bob@aol.com"
  #     email_signup_macro({email: email})
  #     signup_without_newsletter_macro({email: email})
  #     expect(Spree::User.find_by(email: email).newsletter).to be(true)
  #   end

  #    it "makes sure a new non-subscribibg account without a previous newsletter subscription doesn't subscribe" do
  #     email = "bob@aol.com"
  #     # do not sign up for newsletter
  #     expect(EmailSubscriber.find_by(email: email)).to be(nil)
  #     signup_without_newsletter_macro({email: email})
  #     expect(Spree::User.find_by(email: email).newsletter).to be(false)
  #   end
  # end

end
