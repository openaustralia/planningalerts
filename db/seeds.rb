# frozen_string_literal: true

User.create! email: "admin@example.com", password: "password"
authority = Authority.create! full_name: "Marrickville Council",
                              short_name: "Marrickville",
                              state: "NSW",
                              email: "council@marrickville.nsw.gov.au",
                              population_2021: "81489",
                              morph_name: "planningalerts-scrapers/marrickville",
                              website_url: "http://www.marrickville.nsw.gov.au",
                              disabled: false

CreateOrUpdateApplicationService.call(
  authority:,
  council_reference: "DA21/0642",
  attributes: {
    address: "28 Grey Street, Emu Plains NSW 2750",
    description: "Demolition of swimming pool",
    date_scraped: Time.zone.now,
    info_url: "http://bizsearch.penrithcity.nsw.gov.au/ePlanning/Pages/XC.Track/SearchApplication.aspx?id=489056",
    # Values that would normally be the result of geocoding
    suburb: "Emu Plains",
    state: "NSW",
    postcode: "2750",
    lat: -33.7543286,
    lng: 150.6486731
  }
)
