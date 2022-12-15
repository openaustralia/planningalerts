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
* [Flowbite components](https://flowbite.com/#components) are a good reference for starting points on components

## Pages

Trying to systematically list every single page on the site that users can access. These would be all the ones we need to redesign.
Each group is roughly ordered in order of importance (from most important to least important).

| grouping      | path                                      | description
| ------------  | ---------------------------------------   | -----------------------------------------
| Applications  | /applications/:id                         | details of an application
|               | /applications/:id/nearby                  | applications near another application
|               | /applications/trending                    | "trending" applications (lots of comments)
|               | /authorities/:authority_id/applications   | recent applications for a particular authority
|               | /applications                             | all recent applications
| Emails        | N/A                                       | Confirm your alert
|               | N/A                                       | You already have an alert set up
|               | N/A                                       | Email alert
|               | N/A                                       | Confirm your comment
|               | N/A                                       | Comment sent to authority
| Alerts        | /alerts/:id/confirmed                     | You've confirmed your alert
|               | /alerts/:id/area                          | Changing the area of your alert
|               | /alerts/:id/unsubscribe                   | Unsubscribing from your alert
|               | /alerts/signup                            | Signing up for an alert
| User profile  | /profile                                  | Your user profile
|               | /profile/alerts                           | All your alerts
|               | /profile/comments                         | All your comments
|               | /profile/alerts/:id/edit                  | Change the area of one of your alerts
| Documentation | /api/howto                                | How to use the API
|               | /about                                    | About PlanningAlerts
|               | /faq                                      | Frequently asked questions
|               | /get_involved                             | How to get involved
|               | /how_to_write_a_scraper                   | How to write a scraper
|               | /how_to_lobby_your_local_council          | How to lobby your local council
| Landing page  | /                                         | The page on the root of the domain
| Authorities   | /authorities                              | All authorities and the state of their scrapers
|               | /authorities/:id                          | Details for an authority
|               | /authorities/:authority_id/under_the_hood | Details of the scraping for an authority
| Comments      | /comments/:comment_id/reports/new         | Report a comment
|               | /comments/:id/confirmed                   | Confirm a comment you made
|               | /comments                                 | All recent comments
|               | /authorities/:authority_id/comments       | Recent comments for a particular authority
| API login     | /users/sign_in                            | Log in
|               | /users/sign_up                            | Register for an account
|               | /users/edit                               | Edit my account
|               | /users/password/new                       | I forgot my password
|               | /users/password/edit                      | Update my password
|               | /users/confirmation/new                   | Resend confirmation instructions
| ATDIS         | /atdis/test                               | Test an ATDIS feed
|               | /atdis/specification                      | Documentation for the ATDIS specification