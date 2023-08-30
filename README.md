# PlanningAlerts

[![Build Status](https://travis-ci.com/openaustralia/planningalerts.svg?branch=master)](https://travis-ci.com/openaustralia/planningalerts) [![Test Coverage](https://api.codeclimate.com/v1/badges/a7fa0b47c8fdd193bfda/test_coverage)](https://codeclimate.com/github/openaustralia/planningalerts/test_coverage) [![Maintainability](https://api.codeclimate.com/v1/badges/a7fa0b47c8fdd193bfda/maintainability)](https://codeclimate.com/github/openaustralia/planningalerts/maintainability) [![View performance data on Skylight](https://badges.skylight.io/status/JANyIYPM9FwR.svg?token=dDtVtXbOqFPrEZjsGnMPoT-Ss9h3UHtYtZZjFLE9KWo)](https://www.skylight.io/app/applications/JANyIYPM9FwR)

Find out and have your say about development applications in your area.

This is the code for the [web application](https://www.planningalerts.org.au/) side of things written using Ruby on Rails.

If you're interested in contributing a scraper read our [step-by-step guide to writing scrapers](https://www.planningalerts.org.au/how_to_write_a_scraper) on our scraping platform, [morph.io](https://morph.io/).

PlanningAlerts is brought to you by the [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au). It was created by Matthew Landauer and Katherine Szuminska.

## Development

**Install Dependencies**
 * [Docker compose](https://docs.docker.com/compose/install/)

**Checkout The Project**

```
$ git clone https://github.com/openaustralia/planningalerts.git
$ cd planningalerts
```

**Setup The Database**
 * Set up the databases - `docker compose run web bin/rake db:setup`

 **Start the application**
 * `docker compose up`
 * Point your browser at http://localhost:3000

**Run The Tests**
 * In a separate window - `docker compose run web bin/guard`
 * Press enter to run all the tests

### Emails in development

In development all emails are sent locally to [mailcatcher](https://mailcatcher.me/). The emails can be viewed at http://localhost:1080.

### Type checking

We're using [Sorbet](https://sorbet.org/) to add type checking to Ruby which otherwise is a dynamic language. To run the type checker:
```
docker compose run web bin/srb
```

We use Shopify's [tapioca](https://github.com/Shopify/tapioca) gem to manage all our rbi files. We **don't** use `bundle exec srb rbi ...`.

## Deployment

The code is deployed using Capistrano. To deploy to production run:

    bundle exec cap production deploy

This command is defined in `config/deploy.rb`.

Sometimes you want to deploy an alternate branch, for instance when deploying to the `test` stage.
In this case you'll need to set the `branch` variable after recipies are loaded by using the `--set` argument instead of `--set-before`, e.g.

    bundle exec cap staging --set branch=a-branch-i-want-to-test deploy

View more available Capistrano commands with:

    bundle exec cap --tasks

## Upgrading Ruby in production

Upgrading Ruby in production is an unbelievably painful process right now. I'm sorry. Let's make it simpler
but in the meantime:

### Update the application code
* Change `.ruby-version`. Run tests to make sure nothing has broken.

### Upgrade ruby in staging
* In the `oaf/infrastructure` repo update `roles/internal/planningalerts/meta/main.yml` to add the new ruby version before the current one. The last listed one is the default. We don't yet want to change the default
* Install the new ruby on the server by running `ansible-playbook site.yml -l planningalerts`. Remember to set your python virtual environment if you're using that.
* Deploy new version of the application with upgraded `.ruby-version` to staging by running `bundle exec cap staging deploy`
* Login to each webserver in turn (as root user). Then, `cd /srv/www/staging/current; gem install bundler:1.17.3`
* Login to each webserver in turn (as deploy user). Then `cd /srv/www/staging/current; bundle install --gemfile Gemfile --path /srv/www/staging/shared/bundle --deployment --without development test`. This step is necessary if you're upgrading a ruby major version. You might be able to skip it if not.
* Edit `roles/internal/planningalerts/templates/default` to change the ruby version used by passenger for staging
in staging to the new version
* Run ansible again with `ansible-playbook site.yml -l planningalerts`
* Check deployed staging is still working by going https://www.test.planningalerts.org.au

### Upgrade ruby in production
* Deploy new version of the application with upgraded `.ruby-version` to production by running `bundle exec cap production deploy`
* Check deployed production is still working by going https://www.planningalerts.org.au
* Login to each webserver in turn (as deploy user). Then `cd /srv/www/production/current; bundle install --gemfile Gemfile --path /srv/www/production/shared/bundle --deployment --without development test`. This step is necessary if you're upgrading a ruby major version. You might be able to skip it if not.
* Edit `roles/internal/planningalerts/templates/default` to change the ruby version used by passenger for production
in staging to the new version
* Run ansible again with `ansible-playbook site.yml -l planningalerts`
* Check deployed production is still working by going https://www.planningalerts.org.au

During this keep a close eye on disk space on the root partition as this might get close to full

### Tidy up
* Remove old ruby version from `roles/internal/planningalerts/meta/main.yml` in the `oaf/infrastructure` repo
* Rerun ansible with `ansible-playbook site.yml -l planningalerts`
* If you did a ruby major version upgrade (e.g. ruby 2.6.6 to 2.7.4) then you should also clean up an old unused bundler directory that is taking up a lot of space. Login to each webserver in turn (as deploy user). Then `cd /srv/www/staging/shared/bundle/ruby` and remove the unused directory (e.g. `2.6.0`). Do the same for production `cd /srv/www/production/shared/bundle/ruby`.

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
* Email: email address that comments get sent to. Try and find a specific DA comment address or failing that use the main contact email address for the council, e.g. da_comments@bellingen.nsw.gov.au
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

This project is tested with BrowserStack.

## License

GPLv2, see the LICENSE file for full details.
