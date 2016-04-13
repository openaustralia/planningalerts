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
 * Create a `.env.local` file and set your `MORPH_API_KEY`
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

### Configuring PlanningAlerts so people can write to their local councillors

Three conditions must be met for the option to write to councillors to be available for an application:

1. the global feature flag must be toggled on;
2. the feature must be enabled on the authority that the application belongs to; and,
3. there must be councillors associated with the authority for people to write to.

#### Global feature flag

You can toggle the availability of the writing to councillors feature on or off for the entire site with the environment variable `COUNCILLORS_ENABLED`.
The feature is globally enabled when the value of `ENV["COUNCILLORS_ENABLED"]` is `"true"`.
This flag is useful if you need to turn the feature _off_ globally.

We set this in the [`.env`](https://github.com/openaustralia/planningalerts/blob/master/.env) file in production.  You can control setting in development by creating your own `.env.local` file which includes:

```
COUNCILLORS_ENABLED=true
```

#### Enable the feature for an authority

You can toggle the ‘writing to councillors’ options on or off
for all applications under an authority. By default it is off.

Control this setting at the admin page for the authority (e.g. `/admin/authorities/1/edit`).
Check or uncheck the "Write to councillors enabled" option.

You can see which authorities have the feature enabled at the Authorities admin page (`/admin/authorities`).

#### Adding councillors for an authority

You can load in councillors for an authority at its admin page by clicking the “Load Councillors” button.
Councillors for the authority will be loaded in if there is open data for them at [github.com/openaustralia/australian_local_councillors_popolo](https://github.com/openaustralia/australian_local_councillors_popolo).
If you already have them in your database you can update them this way.

If there isn’t any data for councillors at this authority, or the data is incomplete,
follow the [“Updates” instructions at github.com/openaustralia/australian_local_councillors_popolo](https://github.com/openaustralia/australian_local_councillors_popolo#updates).

## Deployment

The code is deployed using Capistrano. To deploy to production run:

    bundle exec cap --set-before stage=production deploy

This command is defined in `config/deploy.rb`.

Sometimes you want to deploy an alternate branch, for instance when deploying to the `test` stage.
In this case you'll need to set the `branch` variable after recipies are loaded by using the `--set` argument instead of `--set-before`, e.g.

    bundle exec cap --set-before stage=test --set branch=a-branch-i-want-to-test deploy

View more available Capistrano commands with:

    bundle exec cap --tasks

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
