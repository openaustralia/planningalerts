# Stores application configuration settings
module Configuration
  # URL Stuff
  HOST = 'dev.planningalerts.org.au'
  INTERNAL_SCRAPERS_INDEX_URL = 'http://dev.planningalerts.org.au:4567/'
  
  # Size of alert areas
  SMALL_ZONE_SIZE = 200
  MEDIUM_ZONE_SIZE = 800
  LARGE_ZONE_SIZE = 2000
  ZONE_BUFFER_PERCENTAGE = 5

  # Email setup
  EMAIL_FROM_ADDRESS = 'contact@planningalerts.org.au'
  EMAIL_FROM_NAME = 'PlanningAlerts.org.au'

  # Scraper params
  SCRAPE_DELAY = 5
  LOG_EMAIL = 'matthew@openaustralia.org'

  # Google maps key
  GOOGLE_MAPS_KEY = 'ABQIAAAAo-lZBjwKTxZxJsD-PJnp8RSar6C2u_L4pWCtZvTKzbAvP1AIvRSM06g5G1CDCy9niXlYd7l_YqMpVg'

  # Google Analytics key
  GOOGLE_ANALYTICS_KEY = "UA-3107958-5"
end
