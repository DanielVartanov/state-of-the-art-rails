Feature: Messages page

  Background:
    Given an author "Mr. Test"
    And an author "Mr. Second test"

    Given a message "First!" by "Mr. Test"
    And a message "Second!" by "Mr. Test"
    And a message "Me too!" by "Mr. Second test"


  Scenario: Loading messages page afresh
    When I go to the "Messages" page
    Then I should see "\"First!\" by Mr. Test"
    And I should see "\"Second!\" by Mr. Test"
    And I should see "\"Me too!\" by Mr. Second test"


  Scenario: Sending a message
    Given I am on the "Messages" page
    When I send a message "Hello from tests!" on behalf of "Mr. Test"
    And I send a message "Hello from another test author" on behalf of "Mr. Second test"
    Then I should see "\"Hello from tests!\" by Mr. Test"
    And I should see "\"Hello from another test author\" by Mr. Second test"

  Scenario: Deleting a message
    Given I am on the "Messages" page
    When I press "Delete" button next to the message "First!"
    Then I should NOT see "\"First!\" by Mr. Test"
    And I should see "\"Second!\" by Mr. Test"
    And I should see "\"Me too!\" by Mr. Second test"

  Scenario: Editing a message
    Given I am on the "Messages" page
    When I press "Edit" button next to the message "First!"
    And I edit the message content to "Edited!"
    Then I should see "\"Edited!\" by Mr. Test"
    And I should NOT see "\"First!\" by Mr. Test"

  Rule: Messages are realtime

    Scenario: Seeing a message created in another browser window
      Given I am on the "Messages" page
      When I open another browser window
      And I go to the "Messages" page
      And I send a message "Hello from another browser window" on behalf of "Mr. Second test"
      And I close another browser window
      Then I should see "\"Hello from another browser window\" by Mr. Second test"

    Scenario: Seeing a message edited in another browser window
      Given I am on the "Messages" page
      When I open another browser window
      And I go to the "Messages" page
      And I press "Edit" button next to the message "First!"
      And I edit the message content to "Edited from another window!"
      And I close another browser window
      Then I should see "\"Edited from another window!\" by Mr. Test"
      And I should NOT see "\"First!\" by Mr. Test"

    Scenario: Seeing a message deleted in another browser window
      Given I am on the "Messages" page
      When I open another browser window
      And I go to the "Messages" page
      And I press "Delete" button next to the message "First!"
      And I close another browser window
      Then I should NOT see "\"First!\" by Mr. Test"
      And I should see "\"Second!\" by Mr. Test"

  Rule: Messages are validated

   Scenario: Short message content validation error
     Given I am on the "Messages" page
     When I send a message "." on behalf of "Mr. Test"
     Then I should see "is too short (minimum is 2 characters)"
     And I should NOT see "\".\" by Mr. Test"
