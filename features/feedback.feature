Feature: Give feedback to Council
  In order to affect the outcome of a development application
  As a citizen
  I want to send feedback on a development application directly to the planning authority
    
  Scenario: Giving feedback for an authority without a feedback email
    Given a planning authority "Foo" without a feedback email
    And an application "1" in planning authority "Foo"
    When I go to application page "1"
    Then I should see "Support or object to this application"
    
  Scenario: Adding a comment
    Given a planning authority "Foo" with a feedback email "feedback@foo.gov.au"
    And an application "1" in planning authority "Foo"
    When I go to application page "1"
    Then I should not see "Support or object to this application"
    When I fill in "Comment" with "I think this is a really good ideas"
    And I fill in "Name" with "Matthew Landauer"
    And I fill in "Email" with "example@example.com"
    And I press "Create Comment"
    Then I should see "Now check your email"
    And I should see "Click on the link in the email to confirm your comment"
    And I should receive an email
    When I open the email
    Then I should see "Please confirm your comment" in the email subject
    And the email body should contain a link to the confirmation page for the comment "I think this is a really good ideas"
  
  Scenario: Unconfirmed comment should not be shown
    Given a planning authority "Foo" with a feedback email "feedback@foo.gov.au"
    And an application "1" in planning authority "Foo"
    And an unconfirmed comment "I think this is a really good ideas" on application "1"
    When I go to application page "1"
    Then I should not see "I think this is a really good ideas"

  @wip
  Scenario: Confirming the comment
    Given an unconfirmed comment "I think this is a really good ideas" on application "1"
    When I visit the confirm page for my comment
    Then I should see "Thank you for confirming your comment."
    And I should see "Your comment has been sent off to Foo Council and is now visible on the application page"
    And I should see a link to the application page
    And "Foo Council" should receive an email
    And they should see "I think this is a really good ideas" in the email body
    When I go to the application page
    Then I should see "I think this is a really good ideas"
