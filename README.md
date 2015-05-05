# PlanningAlerts

Find out and have your say about development applications in your area.

This is the code for the [web application](http://www.planningalerts.org.au/) side of things written using Ruby on Rails. The original code from [PlanningAlerts.com](http://www.planningalerts.com), which this app is based on, was written using PHP.

If you're interested in contributing a scraper read our [step-by-step guide to writing scrapers](http://www.planningalerts.org.au/how_to_write_a_scraper) on our scraping platform, [morph.io](https://morph.io/).

PlanningAlerts is brought to you by the [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au). It was adapted for Australia by Matthew Landauer and Katherine Szuminska, and is based on the UK site PlanningAlerts.com, built by Richard Pope, Mikel Maron, Sam Smith, Duncan Parkes, Tom Hughes and Andy Armstrong.

## Development

[![Build Status](https://travis-ci.org/openaustralia/planningalerts.png?branch=master)](https://travis-ci.org/openaustralia/planningalerts) [![Coverage Status](https://coveralls.io/repos/openaustralia/planningalerts/badge.png?branch=master)](https://coveralls.io/r/openaustralia/planningalerts?branch=master) [![Code Climate](https://codeclimate.com/github/openaustralia/planningalerts.png)](https://codeclimate.com/github/openaustralia/planningalerts)

**Install Dependencies**
 * Install MySql - On OSX download dmg from [http://dev.mysql.com/downloads/](http://dev.mysql.com/downloads/)
 * Install Sphinx - `brew install sphinx`

**Checkout The Project**
 * Fork the project on Github
 * Checkout the project

**Install Ruby Dependencies**
 * Install bundler and foreman - `gem install bundler foreman`
 * Install dependencies - `bundle install`

**Setup The Database**
 * Create your own database config file - `cp config/database.yml.example config/database.yml`
 * Update the config/database.yml with your root mysql credentials
 * If you are on OSX change the socket to /tmp/mysql.sock
 * Set up the databases - `rake db:setup`
 * Generate Thinking Sphinx configuration - `bundle exec rake thinking_sphinx:configure`

**Run The Tests**
 * Run the test suite - `rake`

### Scraping and sending emails in development

**Step 1 - Scrape DAs**
 * Register on [morph.io](https://morph.io) and [get your api key](https://morph.io/documentation/api).
 * Update `MORPH_API_KEY` in app/models/configuration.rb
 * Run - `rake planningalerts:applications:scrape['marrickville']`

**Step 2 - Setup an Alert**
 * Start servers - `foreman start`
 * Hit the home page - http://localhost:3000
 * Enter an address e.g. 638 King St, Newtown NSW 2042
 * Click the "Email me" link and setup an alert
 * Open MailCatcher and click the confirm link: http://localhost:1080/

**Step 3 - Send email alerts**
 * Run - `rake planningalerts:applications:email`
 * Check the email in your browser: http://localhost:1080/
 * To resend alerts during testing, just set the `last_sent` attribute of your alert to *nil*

## Contributing

* Fork the project on GitHub.
* Make a topic branch from the master branch.
* Make your changes and write tests.
* Commit the changes without making changes to any files that aren't related to your enhancement or fix.
* Send a pull request against the master branch.

## Credits

Our awesome contributors can be found on the [PlanningAlerts site](http://www.planningalerts.org.au/about).

## License

GPLv2, see the LICENSE file for full details.
