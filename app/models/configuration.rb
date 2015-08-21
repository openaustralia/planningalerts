# Stores application configuration settings
module Configuration
  # Stripe is used to process cards and customers
  # for subscriptions. See app/controllers/subscriptions_controller.rb
  STRIPE_PUBLISHABLE_KEY = 'xxxxxxxxxxxxxxxxx'
  STRIPE_SECRET_KEY = 'xxxxxxxxxxxxxxxxx'

  DEVISE_SECRET_KEY = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  SECRET_KEY_BASE = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # It can be useful to temporarily stops API calls being logged
  DISABLE_API_LOGGING = false
end
