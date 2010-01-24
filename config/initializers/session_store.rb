# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_planningalerts-app_session',
  :secret      => 'bb457fc0223f9003b30f720a959bbe2b9d66f92ff0eeec2278be7d1672e961955d7d9515bc26335cfa773f302a7d8bd7fe5e660b64d58e9e5f4fa87c06d65a91'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
