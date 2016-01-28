require 'trello'

Trello.configure do |config|
  config.consumer_key=ENV['TRELLO_CONSUMER_KEY']
  config.consumer_secret=ENV['TRELLO_CONSUMER_SECRET']
  config.oauth_token=ENV['TRELLO_OAUTH_TOKEN']
end

#https://trello.com/1/authorize?key=TRELLO_CONSUMER_KEY_FROM_ABOVE&name=MyApp&response_type=token&scope=read,write,account&expiration=never