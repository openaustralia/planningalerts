# PlanningAlerts

[![Build Status](https://travis-ci.com/openaustralia/planningalerts.svg?branch=master)](https://travis-ci.com/openaustralia/planningalerts) [![Test Coverage](https://api.codeclimate.com/v1/badges/a7fa0b47c8fdd193bfda/test_coverage)](https://codeclimate.com/github/openaustralia/planningalerts/test_coverage) [![Maintainability](https://api.codeclimate.com/v1/badges/a7fa0b47c8fdd193bfda/maintainability)](https://codeclimate.com/github/openaustralia/planningalerts/maintainability)

Find out and have your say about development applications in your area.

This is the code for the [web application](https://www.planningalerts.org.au/) side of things written using Ruby on Rails.

If you're interested in contributing a scraper read our [step-by-step guide to writing scrapers](https://www.planningalerts.org.au/how_to_write_a_scraper) on our scraping platform, [morph.io](https://morph.io/).

PlanningAlerts is brought to you by the [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au). It was created by Matthew Landauer and Katherine Szuminska.

## Development

**Install Dependencies**
 * Install MySql - On macOS download dmg from [http://dev.mysql.com/downloads/](http://dev.mysql.com/downloads/)
 * [Install Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html) - On macOS `brew install elasticsearch; brew services start elasticsearch`
 * [Install Redis](https://redis.io/) - On macOS `brew install redis; brew services start redis`

**Checkout The Project**
 * Fork the project on Github
 * Checkout the project

**Install Ruby Dependencies**
 * Install bundler - `gem install bundler -v '~>1'`
 * Install foreman - `gem install foreman`
 * Install dependencies - `bundle install`

**Setup The Database**
 * Create your own database config file - `cp config/database.yml.example config/database.yml`
 * Update the config/database.yml with your root mysql credentials
 * If you are on OSX change the socket to /tmp/mysql.sock
 * Set up the databases - `bundle exec rake db:setup`

**Run The Tests**
 * Run the test suite - `bundle exec rake`

### Type checking

Ruby is a dynamic language. This makes it great
for quick development with a fun developer experience.

However strong typing can really help.
It gives a greater sense of security when refactoring and working on larger
code-bases.

So, we use [Sorbet](https://sorbet.org/) from Stripe
to add strong typing to PlanningAlerts.

To run the type checker:
```
bundle exec srb
```

This is still a work in progress. We're gradually trying to move the
codebase over to `typed: strict` which enforces typed signatures
for all methods.

Also as Sorbet is relatively new things are bound to change quite quickly.

We use Shopify's [tapioca](https://github.com/Shopify/tapioca) gem to manage all our rbi files. We **don't** use `bundle exec srb rbi ...`.

### Scraping and sending emails in development

**Step 1 - Scrape DAs**
 * Register on [morph.io](https://morph.io) and [get your api key](https://morph.io/documentation/api).
 * Create a `.env.development` file and set your `MORPH_API_KEY`
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

## Deployment

The code is deployed using Capistrano. To deploy to production run:

    bundle exec cap --set-before stage=production deploy

This command is defined in `config/deploy.rb`.

Sometimes you want to deploy an alternate branch, for instance when deploying to the `test` stage.
In this case you'll need to set the `branch` variable after recipies are loaded by using the `--set` argument instead of `--set-before`, e.g.

    bundle exec cap --set-before stage=test --set branch=a-branch-i-want-to-test deploy

View more available Capistrano commands with:

    bundle exec cap --tasks

### Adding a new authority

Someone has just written a new scraper for PlanningAlerts, woohoo! :tada: Now we need to add it to the site.

The first step is to fork their repository into the @planningalerts-scrapers organisation. This gives us control over the repository. If we didn't do that then the person could potentially inject bad data without us noticing. A more likely problem is that they go off and do something else and we have no control of the repository to fix things.

Once you've done that add it to morph and do an initial scrape to get some data. It's always a good idea to check that the scraper is getting the data we expect. Just like you'd do if someone had fixed a scraper and opened a pull request.

Speaking of pull requests, because we've forked the scraper GitHub turns off issues on forked repositories. It's a good idea to switch it back on for ours so that other people can open issues and pull requests against the @planningalerts-scrapers repository.

Now that we have a working scraper and some data we can add the new authority to PlanningAlerts. First, log into the admin backend and browse to the authorities section:

https://www.planningalerts.org.au/admin/authorities

Click _New Authority_ in the top-right of the page. Now fill out all the details, here's what needs to go in each field:

* Full name: The full name of the authority that's displayed throughout the site, e.g. Bellingen Shire Council
* Short name: Used in the URL (must be unique), e.g. bellingen
* State: Short version of the state the authority is in. Must be one of NSW, VIC, QLD, SA, WA, TAS, NT, ACT
* Email: email address that comments get sent to. Try and find a specific DA comment address or failing that use the main contact email address for the council, e.g. da_comments@bellingen.nsw.gov.au
* Website url: URL of the authority's website, e.g. http://www.bellingen.nsw.gov.au/
* Population 2017: Look this up at the Australian Bureau of Statistics (ABS). Look for Estimated Resident Population (ERP). Here's a direct link to the 2017 list http://stat.data.abs.gov.au/Index.aspx?DataSetCode=ABS_ERP_LGA2017. We use this on the about page to calculate how much of the population we cover.
* Scraping, morph name: The morph name of the scraper you just forked, e.g. planningalerts-scrapers/bellingen

Click _Create Authority_. Now scrape some applications so you can see them on the new authority page - click _Scrape_.

Visit the new authority page, e.g. https://www.planningalerts.org.au/authorities/bellingen/

You should see that some applications have already been collected. If not wait a few seconds and refresh the page. Once you've got some do a quick check on a few by clicking _Brownse all recent applications_ and selecting a few. Make sure the comment form is visible (that means you set an email address).

If all looks good then thank the contributor for helping tens of thousands of people get PlanningAlerts by tweeting about it from @PlanningAlerts. It's always fun to @mention the council too, sometimes we get a RT :grinning:

>We've just added @BellingenShire thanks to @LoveMyData. Another 12,886 people can now get PlanningAlerts! e.g. https://www.planningalerts.org.au/applications/898071

## Contributing

* Fork the project on GitHub.
* Make a topic branch from the master branch.
* Make your changes and write tests.
* Commit the changes without making changes to any files that aren't related to your enhancement or fix.
* Send a pull request against the master branch.

## Credits

Our awesome contributors can be found on the [PlanningAlerts site](https://www.planningalerts.org.au/about).

## License

GPLv2, see the LICENSE file for full details.
