require 'rails_helper'

describe "anonymous", :type => :feature do
  describe "accessing /admin" do
    it "should show an authorization error" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      visit '/admin'
      expect(page.current_url).to eq(spree.login_url)
    end
  end
  describe "accessing /reports" do
    it "should show an authorization error" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      visit '/reports'
      expect(page.current_url).to eq(spree.login_url)
    end
  end
end
