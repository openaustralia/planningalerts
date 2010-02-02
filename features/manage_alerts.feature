Feature: Manage alerts
  In order to see new development applications in my suburb
  I want to sign up for an email alert
  
  Scenario: Sign up for email alert
    Given I am on the home page
    When I fill in the email adress with "matthew@openaustralia.org"
    And I fill in the street address with "24 Bruce Road, Glenbrook NSW 2773"
    And I press "Create Alert"
    Then I should see "Now check your email"
    And I should receive an email
