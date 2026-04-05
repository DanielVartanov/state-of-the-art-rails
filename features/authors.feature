Feature: Authors page

  Scenario: Authors index page
    Given an author "Mr. Test"
    When I go to the "Authors" page
    Then I should see "Authors"
    And I should see an author with a name of "Mr. Test" in the list
    And I should see "Go to messages"

  Scenario: Creating a new author
    When I am on the "Authors" page
    And I fill in "Name" with "Mr. Test"
    And I click "Create Author"
    And I should see an author with a name of "Mr. Test" in the list
    And I should see "Go to messages"

  Rule: Invalid authors don't get saved

    Scenario: Short author name validation error
      When I am on the "Authors" page
      And I fill in "Name" with "Xy"
      And I click "Create Author"
      Then I should see "is too short (minimum is 3 characters)"
      And I should NOT see an author with a name of "Xy" in the list
