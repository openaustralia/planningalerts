Feature: Manage alerts
  In order to see new development applications in my suburb
  I want to sign up for an email alert
  
  Scenario: Unsubscribe from an email alert
    Given I have received an email alert for "24 Bruce Rd, Glenbrook" with a size of "2000"
    When I click the "unsubscribe" link in the email alert for "24 Bruce Rd, Glenbrook"
    Then I should see "You have been unsubscribed"
    And I should see "24 Bruce Rd, Glenbrook (within 2 km)"
    And I should not receive email alerts for the street address "24 Bruce Rd, Glenbrook"
    
  Scenario: Change size of email alert
    Given I have received an email alert for "24 Bruce Rd, Glenbrook" with a size of "2000"
    When I click the "change alert size" link in the email alert for "24 Bruce Rd, Glenbrook"
    Then I should see "What size area near 24 Bruce Rd, Glenbrook would you like to receive alerts for?"
    And the "My suburb (within 2 km)" checkbox should be checked
    When I choose "My neighbourhood (within 800 m)"
    And I press "Update size"
    Then I should see "your alert size area has been updated"
    And I should receive email alerts for the street address "24 Bruce Rd, Glenbrook" with a size of "800"
