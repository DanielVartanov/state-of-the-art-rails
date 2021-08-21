Feature: Users page

  Scenario: Users index page
    Given a user "Mr. Test"
    When I go to the "Users" page
    Then I should see "Users"
    And I should see a user with a name of "Mr. Test" in the list
    And I should see "Go to messages"

  Scenario: Creating a new user
    When I am on the "Users" page
    And I fill in "Name" with "Mr. Test"
    And I click "Create User"
    And I should see a user with a name of "Mr. Test" in the list
    And I should see "Go to messages"

  Rule: Invalid users don't get saved

    Scenario: Short user name validation error
      When I am on the "Users" page
      And I fill in "Name" with "Xy"
      And I click "Create User"
      Then I should see "is too short (minimum is 3 characters)"
      And I should NOT see a user with a name of "Xy" in the list
