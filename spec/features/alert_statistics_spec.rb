require "spec_helper"

# feature "Show statistics on alerts" do
# In order to figure out which scrapers to write first
# As a scraper developer
# I want to see how many people have signed up for alerts in each area and whether that area has a scraper written for it already

#  scenario "list all the email alerts by authority" do
#    Alert.create!(email: "foo@openaustralia.org", address: "200 Darley Street, Newtown",
#      radius_meters: "2000")
#    Alert.create!(email: "foo@bar.org", address: "100 Govett Street, Katoomba",
#      radius_meters: "1000")
#    Alert.create!(email: "test@openaustralia.org", address: "100 Bathurst Road, Katoomba",
#      radius_meters: "2000")
#    authority = Authority.create!(full_name: "Blue Mountains", short_name: "Blue Mountains")
#    Application.create!(address: "100 Govett Street, Katoomba", council_reference: "001",
#      date_scraped: Time.now, authority: authority)
#    visit(statistics_alerts_path)

#    page.should have_content("Marrickville, NSW 1")
#    page.should_not have_content("Blue Mountains, NSW")
#  end
# end
