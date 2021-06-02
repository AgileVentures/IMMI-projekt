Feature: Admin can see what version is running in an 'About' modal

  As an admin
  So that I know exactly what version of the website is running
  So that I know what features are/aren't implemented and what bugs are/aren't fixed,
  Show me the application version info in a simple "About.." modal


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | first_name      | last_name | email              | admin | membership_status | member |
      | adminFirstname  | admin     | admin@shf.se       | true  |                   | false  |
      | memberFirstname | member    | member@example.com | false | current_member    | true   |
      | userFirstname   | user      | user@example.com   | false |                   | false  |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |

    And the following applications exist:
      | user_email         | company_number | state    |
      | member@example.com | 5560360793     | accepted |

  # ------------------------------------------------------------------------------------------------

  Scenario: Show About modal
    Given I am logged in as "admin@shf.se"
    And I am on the "home" page
    When I click on t("about")
    Then I should see t("about_info.title")
    And I should see t("about_info.version")


  # -------------------------------------------------------
  # Access to the About menu item

  Scenario: Admin can see 'About' in the login menu
    Given I am logged in as "admin@shf.se"
    And I am on the "home" page
    Then I should see t("about") in the login menu


  Scenario: Members cannot see 'About' in the login menu
    Given I am logged in as "member@example.com"
    And I am on the "home" page
    And I am now a member
    Then I should not see t("about") in the login menu

  Scenario: Users (applicants) cannot see 'About' in the login menu
    Given I am logged in as "user@example.com"
    And I am on the "home" page
    Then I should not see t("about") in the login menu

  Scenario: Visitors cannot see 'About' in the login menu
    Given  I am logged out
    And I am on the "home" page
    Then I should not see t("about") in the login menu
