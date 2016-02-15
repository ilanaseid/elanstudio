# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'


# Spree::ReturnItem::EligibilityValidator::Default.permitted_eligibility_validators = [
#   Spree::ReturnItem::EligibilityValidator::OrderCompleted
# ]

require 'spree/preferable_decorator'

unless ENV['BRAINTREE_PRIVATE_KEY'] && Settings.braintree.use_production_gateway
  Spree::PaymentMethod.class_eval do
    def preferences
      {
        :environment=>"sandbox", :merchant_id=>"x8qs3hnwp2gvqcs7", :merchant_account_id=>nil, :public_key=>"4cwkj9bjrgf9crw8", :private_key=>"9577074424f696d7bf38b0347c183eb9", :client_side_encryption_key=>"MIIBCgKCAQEA60/whTi2sweWAAnjKnMAf7BlrdqqDAq2GcdpNr02YiFV3GvR6DpN4XuwDJ5MvDlGO3zszhwE/F0eitsPE7wfFAKQ0hHjx4/RUGYGSgoBnd3JLYuJ8yBAARNcxErlrisxLDewEGjm3s+oo6ofgIYeBZa1JWt+COhT4FlXaXvJ6sccOI0Bauqkit8dKbPXVyTHpjBpvgL8lSyLF4pV6qwowRK4Bo3w1JDFY6RwMl29j1sXKDJoLMRneBMAFkhlnm+kl6zSx6/cZ0B52EBlXtT++lwlNsZio9emXGzDPC0QfSJp1DND/FwePzwTGp0js963ZcnMfKz+7JHceyrXNz75cwIDAQAB", :server=>"test", :test_mode=>false
      }
    end

  end
end