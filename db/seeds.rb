# frozen_string_literal: true

User.create! email: "admin@example.com", password: "password"
authority = Authority.create! full_name: "Marrickville Council",
                              short_name: "Marrickville",
                              state: "NSW",
                              email: "council@marrickville.nsw.gov.au",
                              population_2017: "81489",
                              morph_name: "planningalerts-scrapers/marrickville",
                              website_url: "http://www.marrickville.nsw.gov.au",
                              disabled: false

authorityTwo = Authority.create! full_name: "Parramatta City Council",
                              short_name: "Parramatta",
                              state: "NSW",
                              email: "council@cityofparramatta.nsw.gov.au",
                              population_2017: "243276",
                              morph_name: "planningalerts-scrapers/multiple_epathway_scraper",
                              website_url: "https://www.cityofparramatta.nsw.gov.au",
                              disabled: false

CreateOrUpdateApplicationService.call(
  authority: authority,
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

CreateOrUpdateApplicationService.call(
  authority: authorityTwo,
  council_reference: "DA/321/2022",
  attributes: {
    address: "110 Wetherill Street North, SILVERWATER NSW 2128",
    description: "Change of use to a vehicle dismantling premises and metal car part storage facility.",
    date_scraped: Time.zone.now,
    info_url: "https://onlineservices.cityofparramatta.nsw.gov.au/ePathway/Prod/Web/GeneralEnquiry/EnquiryDetailView.aspx?Id=725692",
    # Values that would normally be the result of geocoding
    suburb: "Silverwater",
    state: "NSW",
    postcode: "2128",
    lat: -33.83568859225864,
    lng: 151.04994362636435
  }
)
