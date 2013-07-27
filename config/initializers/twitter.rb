Twitter.configure do |config|
  config.consumer_key       = Configuration::TWITTER_CONSUMER_KEY
  config.consumer_secret    = Configuration::TWITTER_CONSUMER_SECRET
  config.oauth_token        = Configuration::TWITTER_OAUTH_TOKEN
  config.oauth_token_secret = Configuration::TWITTER_OAUTH_TOKEN_SECRET
end
