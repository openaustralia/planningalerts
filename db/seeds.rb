# frozen_string_literal: true

User.create! email: "admin@example.com", password: "password"
Authority.create! full_name: "Marrickville Council",
                  short_name: "Marrickville",
                  state: "NSW",
                  email: "council@marrickville.nsw.gov.au",
                  population_2017: "81489",
                  morph_name: "planningalerts-scrapers/marrickville",
                  website_url: "http://www.marrickville.nsw.gov.au",
                  disabled: false
