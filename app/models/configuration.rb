# Stores application configuration settings
module Configuration
  # URL Stuff
  HOST = 'localhost:3000'

  # See https://morph.io/api
  MORPH_API_KEY = "xxxxxxxxxxxxxxxxxxxx"

  # Email setup
  EMAIL_FROM_ADDRESS = 'contact@planningalerts.org.au'
  EMAIL_FROM_NAME = 'PlanningAlerts'
  # Email that bounced emails go to (sets Return-Path header in outgoing email)
  BOUNCE_EMAIL_ADDRESS = EMAIL_FROM_ADDRESS
  # The email that abuse reports are sent to
  EMAIL_MODERATOR = EMAIL_FROM_ADDRESS

  # Scraper params
  SCRAPE_DELAY = 5

  # Google maps key
  # Use the following maps API key if you are running your development instance at http://planningalerts-app.dev
  # This will be the case if you are using pow (http://pow.cx/)
  GOOGLE_MAPS_KEY = 'ABQIAAAAo-lZBjwKTxZxJsD-PJnp8RTctXwaglzRZcFAUhNsPfHMAK74xRSSE3HhjcyVtlJHXKjyRyk_3L4CYA'

  # If you have Google Maps API for Business (OpenAustralia Foundation gets it through the Google Maps API
  # grants programme for charities) uncomment and fill out the two lines below
  #GOOGLE_MAPS_CLIENT_ID = "xxxxxxxxxxx"
  #GOOGLE_MAPS_CRYPTOGRAPHIC_KEY = "xxxxxxxxxxx"

  # Google Analytics key
  GOOGLE_ANALYTICS_KEY = "UA-3107958-5"

  # OAuth details for Twitter application with read access only (for twitter feed on home page)
  TWITTER_CONSUMER_KEY = "xxxxxxxxxxx"
  TWITTER_CONSUMER_SECRET = "xxxxxxxxxxx"
  TWITTER_OAUTH_TOKEN = "xxxxxxxxxxx"
  TWITTER_OAUTH_TOKEN_SECRET = "xxxxxxxxxxx"

  # cuttlefish.io is used to send out emails in production
  CUTTLEFISH_USER_NAME = "xxxxxxxxxxxxxxxxx"
  CUTTLEFISH_PASSWORD = "xxxxxxxxxxxxxxxxxxxx"

  # Configuration for the theme
  THEME_NSW_HOST = "nsw.127.0.0.1.xip.io:3000"
  THEME_NSW_EMAIL_FROM_ADDRESS = "contact@nsw.127.0.0.1.xip.io"
  THEME_NSW_EMAIL_FROM_NAME = "Application Tracking"

  THEME_NSW_CUTTLEFISH_USER_NAME = "xxxxxxxxxxxxxxxxx"
  THEME_NSW_CUTTLEFISH_PASSWORD = "xxxxxxxxxxxxxxxxxxxx"

  THEME_NSW_GOOGLE_ANALYTICS_KEY = "UA-3107958-12"

  HONEYBADGER_API_KEY = 'xxxxxxxx'
end
