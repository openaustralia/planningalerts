# Disabled because this feature is currently killing our mysql server

#Feature: Show statistics on alerts
#  In order to figure out which scrapers to write first
#  As a scraper developer
#  I want to see how many people have signed up for alerts in each area and whether that area has a scraper written for it already
  
#  Scenario: list all the email alerts by authority
#    Given the following email alerts:
#      | email                  | address                     | radius_meters |
#      | foo@openaustralia.org  | 200 Darley Street, Newtown  | 2000          |
#      | foo@bar.org            | 100 Govett Street, Katoomba | 1000          |
#      | test@openaustralia.org | 100 Bathurst Road, Katoomba | 2000          |
#    And the following development applications:
#      | address                     | council_reference | scraper        |
#      | 100 Govett Street, Katoomba | 001               | Blue Mountains |
#    When I go to the alerts statistics page
#    Then I should see "Marrickville, NSW 1"
#    And I should not see "Blue Mountains, NSW"
