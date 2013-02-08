Feature: Give feedback to Council
  In order to affect the outcome of a development application
  As a citizen
  I want to send feedback on a development application directly to the planning authority
    
  Scenario: Reporting abuse on a confirmed comment
    Given a moderator email of "moderator@planningalerts.org.au"
    And a confirmed comment "I'm saying something abusive" by "Jack Rude" with email "rude@foo.com" and id "23"
    When I go to the report page for comment "I'm saying something abusive"
    And I fill in "Your name" with "Joe Reporter"
    And I fill in "Your email" with "reporter@foo.com"
    And I fill in "Details" with "You can't be rude to people!"
    And I press "Send report"
    Then I should see "The comment has been reported and a moderator will look into it as soon as possible."
    And I should see "Thanks for taking the time let us know about this."
    And "moderator@planningalerts.org.au" should receive an email
    When they open the email
    Then they should see the email delivered from "Joe Reporter <reporter@foo.com>"
    And they should see "PlanningAlerts: Abuse report" in the email subject
