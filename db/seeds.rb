# frozen_string_literal: true

User.create! email: "admin@example.com", password: "password"
User.create! email: "jane@example.com", password: "password"
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

# A second authority whose scraper is still working, so a real import can be tried in development
logan = Authority.create! full_name: "Logan City Council",
                          short_name: "Logan",
                          state: "QLD",
                          email: "council@logan.qld.gov.au",
                          population_2021: "345098",
                          morph_name: "planningalerts-scrapers/logan",
                          website_url: "http://www.logan.qld.gov.au/",
                          wikidata_id: "Q1782552",
                          asgs_2021: "LGA34590",
                          disabled: false

CreateOrUpdateApplicationService.call(
  authority: logan,
  council_reference: "BW-5279/2009",
  attributes: {
    address: "1 Pitt Court Crestmead QLD 4132",
    description: "Domestic - Shed",
    date_scraped: Time.zone.now,
    info_url: "http://pdonline.logan.qld.gov.au/modules/applicationmaster/default.aspx?page=found&7=5279&8=2009",
    # Values that would normally be the result of geocoding
    suburb: "Crestmead",
    state: "QLD",
    postcode: "4132",
    lat: -27.693237,
    lng: 153.078117
  }
)
