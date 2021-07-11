Feature: Users page

  @javascript
  Scenario: Users index page
    When I go to the "Users" page
    Then I should see "Users"
    And I should see "Go to messages"


  @javascript
  Scenario: Creating a new user
    When I go to the "Users" page
    And I fill in "Name" with "Mr. Test"
    And I click "Create User"
    Then I should see "Mr. Test"
    And I should see "Go to messages"
