# Manual Test on Dev

This document outlines how to test a local dev environment for the major functionality,
Checking functionality and look and feel.  
It will reference sections in `../README.md` rather than repeat them.


## Get the server running

Follow the steps in the Development section, including:

* Install Dependencies (only needed once)
* Checkout The Project (only needed once)
* Start the application
* Ports and multiple worktrees (if you have port conflicts)
* If the app won't start (if needed)
* Setup Development Data (the initial data)
* Emails in development (read it, you will need it)

## Built-in development paths

`make status` shows the app and mailcatcher urls - open them both

Rails serves these pages in development only - append these to the app url:

* `/rails/mailers`: preview mail templates with example data in the browser.
  * The example alert email is also available from the admin: Your name > Administration panel > Test Emails.
  * Testing rate limit: If you ctrl-click through all the templates quickly, the last few will hit the rate limit.
* `/rails/info/routes`: a searchable list of every route, HTTP verb and controller action.
* `/rails/info/properties`: the Rails, Ruby, middleware and environment details .


## Test Data

Run the following to see how many records each table has in the dev seed data:

```bash
make shell # for a bash shell

bin/rake db:stats
exit
```

Run the following to see the important test data:

```bash
make console # for a rails console

Authority.all
Application.all
User.all
exit
```

## Public pages

Start at the Home page, as reported by `make status`, and reach every page by clicking in the header, side-bar or footer, as a person would. This checks people can navigate through the site. 

Check each page loads without an error and looks right, especially pages that have changed recently.

The seed data gives you two authorities, each with one application: Logan City Council (69 Fedrick Street, Boronia Heights) and
Marrickville Council (28 Grey Street, Emu Plains). Use Logan: its scraper still works, and Marrickville's no longer does,
so its external links are broken.

Navigate to the following:

* Home > Search: the address search (see Maps below).
* Footer > Coverage > Logan City Council: the authority page. From there follow 
  * "recent applications",
    * select 69 Fedrick Street, Boronia Heights: the application. It
      shows the details, the map (see Maps below) and the comment form. Its version history is linked from the application
      page. 
      * Add a comment 
  * "comments on applications" and
  * "look under the hood".
  
* Home, then the trending applications and the stats shown on the page, and each link from there.
* Top menu > Planning Alerts API: the API how-to, then follow its link to the developer page.
* Top menu > Help: the FAQ, then Footer > About, Get involved and Contact us.
* The full text search is behind the `full_text_search` Flipper feature. Switch it on as the admin (Your name >
  Feature flags) and check Search then offers it. Without the feature it says it is not enabled.

## Admin Login

Two people are used for testing: the administrator `admin@example.com` (created by the seed data) and a normal
person, `jane@example.com` (Jane Citizen). The seed data creates both, and both use the password `password`.

1. Check a user that has not confirmed is unable to login: try to sign in as `admin@example.com` before confirming.
2. Confirm the administrator: open mailcatcher at <http://localhost:1080>, select the first email (subject:
   PlanningAlerts: Confirmation instructions) and click "Create my account". After that you can sign in as
   `admin@example.com`.
3. Make that user an administrator (see Setup Development Data in the README). Run this in `make console`:

   ```ruby
   User.find_by(email: "admin@example.com").add_role(:admin)
   ```

   Then sign in again (Home > Sign In) and click Your name > Administration panel.
4. Check Jane cannot sign in yet: sign out (Your name > Sign out), then Home > Sign In as `jane@example.com`. She is not
   confirmed.
5. Confirm Jane: in mailcatcher, open the confirmation email addressed to `jane@example.com` and click the link. Sign
   in as her and check she can reach her alerts by clicking her name, and that there is no Administration panel link. Also try browsing to `/admin` directly: it should be refused.


## Admin pages

Sign in as the administrator, then click Your name (top right) > Administration panel. The sidebar lists: Homes,
Users, Alerts, Comments, Reports, Authorities, Applications, Api Keys, Api Usages, Background Jobs, Test Emails, Roles
and Announcements, with a "Back to app" button at the top. Open each and check it loads without an error:

* Users, Alerts, Comments, Reports, Authorities, Applications, Announcements
* Applications > open one > check its version history shows (it uses `administrate-field-paper_trail`)
* Roles: the `admin` role should be listed, and opening it should work
* Api Keys and Api Usages
* Test Emails: the form sends an example alert email (see Alerts and emails)
* Background Jobs: this opens the Sidekiq dashboard (see Background jobs)
* Back to app, then Your name: the Feature flags (Flipper) and A/B Testing (Split) links under the Administration panel



## Alerts and emails

All development email goes to mailcatcher at <http://localhost:1080> (see Emails in development in the README).

* Sign up for an alert: Home > Search, or Your name > Create new alert. It needs an address that can be geocoded, so it
  needs the Google keys (see Maps). Confirm it from the email in mailcatcher, then check it is listed under
  Your name > Your alerts and in the admin under Alerts.
* Send an example alert email, with `make shell` then
  `bin/rake "development:test_alert[you@example.com]"`, or use Administration panel > Test Emails. In mailcatcher, open it and check
  the layout, the images, the links and the unsubscribe link.
* To work on the email layout, use the Maizzle preview at <http://localhost:3000/rails/mailers/>.


## Comments

1. On an application page, write a comment. Check the confirmation email arrives in mailcatcher, and follow its link.
2. Check the comment shows on the application page and under Your name > Your comments, and in the admin under Comments.
3. Check an email addressed to the authority (the seed data uses `council@logan.qld.gov.au` for Logan) arrives in
   mailcatcher. In the admin, the "Resend email" button on that comment sends it again.


## The API

The `api` hostnames only serve the API in development, as in production. See Accessing the API in development in the
README for the hostnames and a `curl` example.

1. Sign in and create an API key: Your name > Your API keys.
2. Run `curl "http://api.pa.org.localhost:3000/authorities.json?key=<your key>"`. It should return JSON.
3. Try the other formats and requests listed on the developer page (Top menu > Planning Alerts API, then the developer link).
4. Check the call shows up in the admin under API usages. It is counted by a background job, so this also checks
   Sidekiq is running.


## Background jobs

`make up` runs a Sidekiq worker alongside Rails. After you have sent some email above, open the Sidekiq dashboard (Administration panel > Background Jobs) and
check a worker process is connected and nothing is stuck under Retries or Dead.

Importing applications is not configured for the development environment yet. The "Import applications" button on an
authority in the admin queues `ImportApplicationsJob`, which needs a `morph_api_key` in the Rails credentials. Development
has none, so the job fails with `TypeError: Parameter 'morph_api_key': Expected type String, got type NilClass` and
keeps retrying under Retries. Don't click it for now. If you did, delete the entry from Retries. This is part of getting
development keys sorted out in openaustralia/oaf-internal#374.


## Maps

**Google Maps are presently not configured in development** - As the server is unable look up the lat and long location of an address, this following will fail:
- Search by address
- Add an alert  

Static maps, street view and address lookups need Google Maps keys in the Rails credentials. Without them the map and
street view images are requested without a key, so Google returns an error image instead of a map, and an address
cannot be geocoded. Skip the checks that need an address (signing up for an alert, the address search). The specs use
recorded responses and do not need the keys. Getting the keys for local
development is being sorted out in openaustralia/oaf-internal#374.

With keys, check the application page shows a map and a street view, and that searching for
`69 Fedrick Street, Boronia Heights QLD 4124` finds the seeded Logan application (or `28 Grey Street, Emu Plains NSW 2750` for
Marrickville).


## After a deploy

There is no staging server, so after Rails or a dependency is upgraded, these checks are done in production once the new version is live. Tick them off in the issue for the upgrade.

* [ ] A public page loads, and so do an authority page and an application page.
* [ ] An alert email arrives and its links work: send one to a staff address from Administration panel > Test Emails.
* [ ] Comment emails to councils still go out. Do not post test comments to a real council. Check the
  `planningalerts-comments` Postal server shows recent deliveries, and that Slack has no failed or held comment
  notices.
* [ ] The admin interface loads, including Roles and an application's version history.
* [ ] The real visitor IP address is still seen behind Cloudflare (`cloudflare-rails` only loads in production).
  Switch on the `provide_whatismyip` Flipper feature (it is off by default) and run
  `curl https://www.planningalerts.org.au/whatismyip`. It should print your IP without ` FAIL` (see the whatismyip
  section of the README). New signups also record `signup_ip` on the admin alert and user pages.
* [ ] Sidekiq is working: on the Sidekiq dashboard (Administration panel > Background Jobs) the workers are connected, the queues are not growing, and Retries and
  Dead are not filling up.
* [ ] Sentry (org `oaf-org-au`, project `planning-alerts`) shows no new issues from the release.




