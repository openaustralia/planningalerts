# PlanningAlerts

[![Build Status](https://travis-ci.org/openaustralia/planningalerts.svg?branch=master)](https://travis-ci.org/openaustralia/planningalerts) [![Coverage Status](https://coveralls.io/repos/github/openaustralia/planningalerts/badge.svg?branch=master)](https://coveralls.io/github/openaustralia/planningalerts?branch=master) [![Maintainability](https://api.codeclimate.com/v1/badges/a7fa0b47c8fdd193bfda/maintainability)](https://codeclimate.com/github/openaustralia/planningalerts/maintainability)

Find out and have your say about development applications in your area.

This is the code for the [web application](http://www.planningalerts.org.au/) side of things written using Ruby on Rails. The original code from [PlanningAlerts.com](http://www.planningalerts.com), which this app is based on, was written using PHP.

If you're interested in contributing a scraper read our [step-by-step guide to writing scrapers](http://www.planningalerts.org.au/how_to_write_a_scraper) on our scraping platform, [morph.io](https://morph.io/).

PlanningAlerts is brought to you by the [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au). It was adapted for Australia by Matthew Landauer and Katherine Szuminska, and is based on the UK site PlanningAlerts.com, built by Richard Pope, Mikel Maron, Sam Smith, Duncan Parkes, Tom Hughes and Andy Armstrong.

## Table of Contents

* [Development](#development)
  * [Scraping and sending emails in development](#scraping-and-sending-emails-in-development)
  * [Take regular donations through PlanningAlerts with Stripe](#take-regular-donations-through-planningalerts-with-stripe)
  * [Configuring PlanningAlerts so people can write to their local councillors](##configuring-planningalerts-so-people-can-write-to-their-local-councillors)
    * [Global feature flag](#global-feature-flag)
      * [Writing to councillors feature](#writing-to-councillors-feature)
      * [Contributing suggested councillors feature](#contributing-suggested-councillors-feature)
    * [Set the reply address for accepting responses](#set-the-reply-address-for-accepting-responses)
    * [Enable the feature for an authority](#enable-the-feature-for-an-authority)
    * [Adding councillors for an authority](#adding-councillors-for-an-authority)
    * [Accepting councillor replies](#accepting-councillor-replies)
      * [Default Wizard of Oz method](#default-wizard-of-oz-method)
      * [Integrating with WriteIt](#integrating-with-writeit)
    * [Processing councillor data contributions](#processing-councillor-data-contributions)
* [Deployment](#deployment)
  * [Adding a new authority](#adding-a-new-authority)
* [Contributing](#contributing)
* [Credits](#credits)
* [License](#license)

## Development

**Install Dependencies**
 * Install MySql - On macOS download dmg from [http://dev.mysql.com/downloads/](http://dev.mysql.com/downloads/)
 * Install Sphinx - On macOS `brew install sphinx`
 * Install PhantomJS for headless browser testing with Poltergeist - follow
   [instructions in the Poltergeist Readme](https://github.com/teampoltergeist/poltergeist#installing-phantomjs).

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
 * Set up the databases - `bundle exec rake db:setup`
 * Generate Thinking Sphinx configuration - `bundle exec rake ts:configure`

**Run The Tests**
 * Run the test suite - `bundle exec rake`

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

### Take regular donations through PlanningAlerts with Stripe

You can configure PlanningAlerts to allow people to donate to the project monthly.
[Stripe](https://stripe.com) is used to process the payment and manage billing.

You need to configured three evironment variables in your .env.development file
to allow users to visit the donations page.

1. The publishable API key from your stripe account.
2. The secret API key from your stripe account.
3. The ID for a [Stripe subscription plan](https://stripe.com/docs/subscriptions/quickstart)
   **with the amount/price of $1** (the amount/price is really important, if it isn't $1 you'll over charge people).

```
# Stripe is used to process cards and manage billing for donations.
# See app/controllers/donations_controller.rb
# STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxx
# STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxxxxx
# Stripe plan ID for recurring donation subscription.
# You need to make a subscription plan on stripe with the value of $1.
# Replace the example id for the plan here
# STRIPE_PLAN_ID_FOR_DONATIONS=example-planningalerts-subscribers-1
```

### Configuring PlanningAlerts so people can write to their local councillors

People use PlanningAlerts to provide official submissions to planning applications,
but sometimes the official process doesn’t work well, or they have questions and need a response.
In Australia we elect local councillors to represent us in local government decision making—these are good people to speak to in these cases and many others.
Through PlanningAlerts people can send public messages to their councillors about planning applications *and* councillors can reply.

Developers will find a detailed explanation of how the feature works in this section.
Administrators will be most interested in [how to add councillors for an authority](#adding-councillors-for-an-authority).

Four conditions must be met for the option to write to councillors to be available for an application:

1. the global feature flag must be toggled on;
2. a reply address must be configured for councillors to email their responses to;
3. the feature must be enabled on the authority that the application belongs to; and,
4. there must be councillors associated with the authority for people to write to.

You will also need to [configure the app to accept replies from councillors](#accepting-councillor-replies).

#### Global feature flag

##### Writing to councillors feature
You can toggle the availability of the writing to councillors feature on or off for the entire site with the environment variable `COUNCILLORS_ENABLED`.
The feature is globally enabled when the value of `ENV["COUNCILLORS_ENABLED"]` is `"true"`.
This flag is useful if you need to turn the feature _off_ globally.

We set this in the [`.env`](https://github.com/openaustralia/planningalerts/blob/master/.env) file in production.  You can control setting in development by creating your own `.env.development` file which includes:

```
COUNCILLORS_ENABLED=true
```
##### Contributing suggested councillors feature
Similarly, you can toggle the availability of the contributing suggested councillors feature on or off for the entire site with the environment variable `CONTRIBUTE_COUNCILLORS_ENABLED`.
The feature is globally enabled when the value of `ENV["CONTRIBUTE_COUNCILLORS_ENABLED"]` is `"true"`.
This flag is useful if you need to turn the feature _off_ globally.

We set this in the [`.env`](https://github.com/openaustralia/planningalerts/blob/master/.env) file in production.  You can control setting in development by creating your own `.env.development` file which includes:

```
CONTRIBUTE_COUNCILLORS_ENABLED=true
```


#### Set the reply address for accepting responses

You need to specify an email address for councillors to send their replies to.
If you’re using the [‘Wizard of Oz’ setup](#default-wizard-of-oz-method), the councillor replies will come in to this address.
If you’re using the [WriteIt integration](#intergrating-with-writeit), then the WriteIt answer notification emails will be sent there.

Set this address using the `EMAIL_COUNCILLOR_REPLIES_TO` environment variable in [`.env`](https://github.com/openaustralia/planningalerts/blob/master/.env) or `.env.development` in your local development setup:

```
EMAIL_COUNCILLOR_REPLIES_TO=lovely@email.org.au
```

#### Enable the feature for an authority

You can toggle the ‘writing to councillors’ options on or off
for all applications under an authority. By default it is off.

Control this setting at the admin page for the authority (e.g. `/admin/authorities/1/edit`).
Check or uncheck the "Write to councillors enabled" option.

You can see which authorities have the feature enabled at the Authorities admin page (`/admin/authorities`).

#### Adding councillors for an authority

If you'd like to add new councillors for a planning authority, there are a number of steps that you need to take across a few different online services:

1. Firstly, **make sure the data for your councillors is available from the [`australian_local_councillors_popolo` repository](https://github.com/openaustralia/australian_local_councillors_popolo)**. Follow its [instructions for adding new councillor data there](https://github.com/openaustralia/australian_local_councillors_popolo#updates).
2. If you're [using WriteIt](#integrating-with-writeit) then the next step is to **refresh the data source in WriteIt so it knows about the coucillors you've added to the popolo data**.

   **Confirm that you can now find the new councillors by searching for their names in the [WriteIt _frontend_](http://planningalerts.writeit.ciudadanointeligente.org/en/write/who/)**. Just because they are present in the [Recipents Page](http://planningalerts.writeit.ciudadanointeligente.org/en/manage/recipients/) or [in the API](http://planningalerts.writeit.ciudadanointeligente.org/en/manage/settings/api/) does not mean their emails have been loaded and they are contactable.
4. **Run [the morph.io scraper](https://morph.io/openaustralia/australian_local_councillors_images) that copies the councillor’s images for use in PlanningAlerts**. Wait for it to finish running before continuing so that the councillors images are available for PlanningAlerts.
5. Now **visit the authority admin page and click the “Load Councillors” button**.
Any new councillors for this authority will be added, and existing councillors will be updated.
6. Finally, check the list of your new and/or updated councillors on the authority’s admin page.
7. If you're happy with the result then **[enable writing to councillors for this authority](#enable-the-feature-for-an-authority)**.

#### Accepting councillor replies

Not only can people write to their councillors using PlanningAlerts, but councillors can also reply!

When someone writes to their local councillor, the councillor receives an email with the message.
To reply, they simply reply to the email.
The reply is then posted below the original comment on PlanningAlerts, and the commenter is notified.
Replies are featured in alert emails like normal comments.

You can choose between two different methods for loading replies into PlanningAlerts:
The [‘Wizard of Oz’ setup](#default-wizard-of-oz-method), which requires administrators to watch an email inbox and manually enter replies;
or, by [integrating with a WriteIt site](#intergrating-with-writeit), which will accept replies and have them automatically posted on PlanningAlerts.

##### Default Wizard of Oz method

While the back and forth of writing to councillors appears to be automatic to users, by [default there is no magic](https://en.wikipedia.org/wiki/Wizard_of_Oz_experiment).
Behind the scenes administrators need to manually collect replies from an email inbox and add them to people’s comments.

By default, the reply address on the email sent to councillors will be the address you set with `ENV["EMAIL_COUNCILLOR_REPLIES_TO"]`.
You can follow the [instructions above for setting the reply address](#set-the-reply-address-for-accepting-responses) if you haven’t yet.

When a councillor replies to an email with someone’s message, like normal email, the reply will go to the inbox of the reply address.
You will need to keep an eye on this inbox for incoming replies.

When a councillor reply email arrives you will need to manually add it to PlanningAlerts.
To add a reply, first find the comment it is responding to on the comments index page or page for the application it is associated with.
If you are logged in as an Admin, there will be a link “Add reply” on the bottom of the comment.

On the ‘Add reply’ page fill in the form with the details of the reply:
the `comment_id` of the comment it is responding to, the name of the councillor, the full text of the email received, and the time it was received (in [UTC time](http://time.is/UTC)).
Hit the “Create reply” button. The original commenter will be notified of the reply via email and the reply will be posted with the comment on the application page.

##### Integrating with WriteIt

PlanningAlerts can automatically post replies from councillors
by integrating with [WriteIt](http://writeit.ciudadanointeligente.org/en/) to send messages and receive answers.
This means that no action is required by administrators for councillor replies to be loaded.

###### Basic setup

To send people’s comments to councillors via a WriteIt instance, PlanningAlerts needs to know some things about that instance:

* the URL of the WriteIt app you’re using;
* the location of your ‘site’ within that app;
* your username for the WriteIt app; and,
* your API key.

If you want to use the [version of WriteIt publicly hosted by Fundación Ciudadano Inteligente](http://writeit.ciudadanointeligente.org/)
then sign up for an account and create your own ‘site’ over there.
On the API page for your WriteIt site you’ll find the information you need.

The information about the WriteIt instance you will be working with is stored as environment variables.
In production these should be in a `.env` file.
Use `.env.development` in your local development environment.

```
# WriteIt configuration
WRITEIT_BASE_URL=http://writeit.ciudadanointeligente.org
WRITEIT_URL=/api/v1/instance/1234/
WRITEIT_USERNAME=yourusername
WRITEIT_API_KEY=xxxxxxxxxxxxyourapikeyxxxxxxxxxxxxxxxxxx
```

###### Adding your councillor data to WriteIt

You’ve already [loaded your councillors into PlanningAlerts](#adding-councillors-for-an-authority),
now you need to load them into WriteIt.

You can add ‘recipients’ to your WriteIt site by adding a new ‘data source’.
On the ‘Data Sources’ page for your WriteIt site add a new ‘Popolo URL’ for each of the councillor popolo files at [github.com/openaustralia/australian_local_councillors_popolo](https://github.com/openaustralia/australian_local_councillors_popolo/),
e.g. :

```
https://raw.githubusercontent.com/openaustralia/australian_local_councillors_popolo/master/nsw_local_councillor_popolo.json
```

When you add the ‘data source’ WriteIt loads in all [Popolo People objects](http://www.popoloproject.com/specs/person.html) available.
You will be able to send messages to the people who have an email address.

Every time you want to add new councillors or change their details, you need to load that data into WriteIt in addition to [loading the changes into PlanningAlerts](#adding-councillors-for-an-authority).
On the Writeit ‘data sources’ page you can “fetch new data” to update your available ‘recipients’.

It’s always a good idea to check that your update worked as expected by [seeing if you have the option to write to one of the newly added councillors in WriteIt](http://planningalerts.writeit.ciudadanointeligente.org/en/write/who/).

###### Sending messages via WriteIt

PlanningAlerts decides how to send a comment [after it is confirmed](https://github.com/openaustralia/planningalerts/blob/master/app/models/comment.rb#L30-L38) by the user.
If you’ve [configured the integration to a WriteIt site](#basic-setup),
comments to councillors will automatically be sent via the WriteIt API.

###### Automatically fetching replies with the _Writeit reply webhook_

When a councillor receives a message that has been sent via WriteIt,
the reply email address is a special WriteIt email address, not [your configured reply address](#set-the-reply-address-for-accepting-responses).
When they reply to the email, the content of their email is automatically added
as an answer to the original message on WriteIt.

You can add the PlanningAlerts [_WriteIt reply webook_](https://github.com/openaustralia/planningalerts/blob/master/app/controllers/comments_controller.rb#L42-L49) to your Writeit site
to automatically load these replies into PlanningAlerts.

On the Wehbooks settings page for your WriteIt site,
add the webhook URL for your PlanningAlerts setup as a new webhook URL, e.g.:

```
http://planningalerts.com/comments/writeit_reply_webhook
```

Now, when a new reply is created on your WriteIt site,
WriteIt will post data about it to the webhook URL you set.

Your PlanningAlerts app will then fetch the full answer from WriteIt
and create a new reply.

###### Manually loading replies from Writeit

If for some reason the webhook isn’t configured,
or something else goes wrong, you can manually load replies from your WriteIt site.

Navigate to the admin page for a comment, e.g. `/admin/comments/123`.
Use the “Load replies from WriteIt” button to load in new replies to that comment.
PlanningAlerts will fetch any answers from the API for your WriteIt site
and create new replies and associate them with the comment.

#### Processing councillor data contributions

It's important that the lists of councillors that people can write to stay up-to-date.
To help you update the listings, PlanningAlerts invites people to contribute data to maintain the list of councillors for their local area.

When contributions come in, they are listed on the admin page for Councillor Contributions.
An email is also sent to the administrator email address to notify you—at the OpenAustralia Foundation we've configured these emails to be forwarded to our Slack channel for higher visibility.

To review and ingest the contribution:

1. Find the contribution on the Councillor Contributions admin page (`/admin/councillor_contributions`).
2. Review the list of suggested councillors.
   The person has been asked to provide information about the source of the data, and their contact information to assist you in reviewing their contribution.
3. If the contribution is acceptable hit the 'Download the suggested councillors CSV' button.
4. You can make changes to the data at this point if you want to adjust it or add more fields for the councillors.
5. Take this CSV and contribute it to the [repository for structured data of Australian local councillors](https://github.com/openaustralia/australian_local_councillors_popolo)
   following [its 'Updates' instructions](https://github.com/openaustralia/australian_local_councillors_popolo/#updates)

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

(Unfortunately there's a bug that's making this take ages, FIXME: https://github.com/openaustralia/planningalerts/issues/1158)

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

Our awesome contributors can be found on the [PlanningAlerts site](http://www.planningalerts.org.au/about).

## License

GPLv2, see the LICENSE file for full details.
