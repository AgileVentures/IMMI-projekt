Feature: Must be logged in as admin to get to the test exception notification URL

  As an admin
  So that we can verify that exception notifications are working
  And so that the url is not found by bots and malicous users
  Make the URL available only to logged-in admins


  Background:

    Given the following users exist
      | email               | admin | member |
      | emma@happymutts.com |       | true   |
      | anna@sadmutts.com   |       |        |
      | admin@shf.se        | true  |        |



  Scenario: Admin can access the exception notification path
    Given I am logged in as "admin@shf.se"
    Then the url "test_exception_notifications" should be a valid route
    And the page should not be blank

    
  Scenario: A member cannot access the exception notification path
    Given I am logged in as "emma@happymutts.com"
    Then the url "test_exception_notifications" should not be a valid route
    And the page should be blank


  Scenario: A user cannot access the exception notification path
    Given I am logged in as "anna@sadmutts.com"
    Then the url "test_exception_notifications" should not be a valid route
    And the page should be blank


  Scenario: A visitor cannot access the exception notification path
    Given I am logged out
    Then the url "test_exception_notifications" should not be a valid route
    And the page should be blank




