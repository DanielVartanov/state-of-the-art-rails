Feature: Messages page

  Background:
    Given a user "Mr. Test"
    And a user "Mr. Second test"

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

  Rule: Messages are realtime

    Scenario: Seeing a message created in another browser window
      Given I am on the "Messages" page
      When I open another browser window
      And I go to the "Messages" page
      And I send a message "Hello from another browser window" on behalf of "Mr. Second test"
      And I close another browser window
      Then I should see "\"Hello from another browser window\" by Mr. Second test"
