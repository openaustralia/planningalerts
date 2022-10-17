# Visual design

The site is long overdue a visual redesign. It's currently clunky, inconsistent, ugly and not as readable and accessible as it really should be.

Some initial thoughts on what the new design should have:
* Simple 
* Extremely legible
* Accessible
* Human
* with small touches of whimsy
* Not be government

Maybe we could use some [illustrations of people](https://www.drawkit.com/product/team-work-illustrations) rather than photos to add some whimsy?

[They Vote for You](https://theyvoteforyou.org.au) manages to not look like a government site by using large blocks of colour

It might be helpful to have screenshots of every single page on the site that is accessible to normal users. This should also include the emails.

## Technical bits and pieces

Thinking of using the following bits of technology to implement the redesign:

* [Tailwind CSS](https://tailwindcss.com/)
* [View Components](https://viewcomponent.org/)
* [Maizzle](https://maizzle.com/) (for emails)

## Pages

Trying to systematically list every single page on the site that users can access. These would be all the ones we need to redesign.
Each group is roughly ordered in order of importance (from most important to least important).

### Applications

* /applications/:id/nearby
* /applications/trending
* /applications
* /applications/:id
* /authorities/:authority_id/applications

# Emails

* Confirm your comment
* Confirm your alert
* Email alert
* ... There are more

### Alerts

* /alerts/:id/confirmed
* /alerts/:id/area
* /alerts/:id/unsubscribe
* /alerts/signup

# Documentation/help

* /api/howto
* /about
* /faq
* /getinvolved
* /how_to_write_a_scraper
* /how_to_lobby_your_local_council

# Landing page

* /

# Authorities

* /authorities/:authority_id/under_the_hood
* /authorities
* /authorities/:id

### Comments

* /comments
* /comments/:id/confirmed
* /comments/:comment_id/reports/new
* /authorities/:authority_id/comments

### Login/registration for API users

* /users/sign_in
* /users/password/new
* /users/password/edit
* /users/cancel
* /users/sign_up
* /users/edit
* /users/confirmation/new
* /users/confirmation

# ATDIS

* /atdis/test
* /atdis/feed/:number/atdis/1.0/applications.json
* /atdis/specification