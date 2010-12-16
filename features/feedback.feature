Feature: Give feedback to Council
  In order to affect the outcome of a development application
  As a citizen
  I want to send feedback on a development application directly to the planning authority
    
  Scenario: Giving feedback for an authority without a feedback email
    Given a planning authority "Foo" without a feedback email
    And an application "1" in planning authority "Foo"
    When I go to application page "1"
    Then I should see "Support or object to this application"
    
  @wip
  Scenario: Giving feedback for an authority with a feedback email
    Given a planning authority "Foo" with a feedback email
    And an application "1" in planning authority "Foo"
    When I go to application page "1"
    Then I should not see "Support or object to this application"
    When I fill in "Subject" with "My opinion"
    And I fill in "Details" with "I think this is a really good ideas"
    And I fill in "Name" with "Matthew Landauer"
    And I fill in "Email" with "matthew@openaustralia.org"
    And I press "Send feedback"
    Then I should see "Now, check your email. You will need to confirm your feedback"
    And I should receive an email with the subject "PlanningAlerts.org.au: Confirm your feedback"
    When I click the first link in the email
    Then I should see "Thank you for confirming your feedback"
    And I should see "I think this is a really good ideas"
    And the planning authority "Foo" should receive an email with "I think this is a really good ideas" in the body
