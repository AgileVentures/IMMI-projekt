Feature:

  As an admin
  I would like to search and sort users
  to find a particular user among many
  and to know which users are members and which are not

  Background:
    Given the following users exist
      | first_name | last_name | email                               | admin | membership_number | member |
      | John       | Adams     | ja@hotmail.com                      | false | 1                 | false  |
      | Sarah      | Connor    | sconnor@example.com                 | false | 2                 | true   |
      | Luke       | Skywalker | luke@force.net                      | false | 14                | false  |
      | admin      | admin     | admin@sverigeshundforetagare.se     | true  | 3                 | false  |
    And the following applications exist:
      | user_email          | state                 | company_number |
      | ja@hotmail.com      | waiting_for_applicant | 0000000000     |
      | sconnor@example.com | accepted              | 0000000000     |
      | luke@force.net      | rejected              | 0000000000     |
    And I am logged in as "admin@sverigeshundforetagare.se"

  Scenario: Admin searches for luke
    Given I am on the "all users" page
    When I fill in t("users.search_form.profile_email") with "luke"
    And I click on t("search")
    Then I should see "luke@force.net"
    And I should not see "sconnor@example.com"

  Scenario: Admin searches for @sverigeshundföretagare.se
    Given I am on the "all users" page
    When I fill in t("users.search_form.profile_email") with "@sverigeshundföretagare.se"
    And I click on t("search")
    Then I should not see "admin@sverigeshundforetagare.se"
    And I should see t("users.index.no_search_results")

  Scenario: Admin searches for membership number
    Given I am on the "all users" page
    And I select "1" in select list t("users.search_form.membership_number")
    And I click on t("search")
    Then I should see "ja@hotmail.com"
    And I should not see "luke@force.net"

  Scenario: Admin sorts users by email
    Given I am on the "all users" page
    When I click on t("users.users_list.email")
    Then I should see "luke@force.net" before "sconnor@example.com"

  Scenario: Admin sorts users by membership number
    Given I am on the "all users" page
    When I click on t("users.users_list.membership_number")
    Then I should see "ja@hotmail.com" before "sconnor@example.com"
    Then I should see "sconnor@example.com" before "admin@sverigeshundforetagare.se"
    Then I should see "admin@sverigeshundforetagare.se" before "luke@force.net"
    When I click on t("users.users_list.membership_number")
    Then I should see "luke@force.net" before "admin@sverigeshundforetagare.se"
    Then I should see "admin@sverigeshundforetagare.se" before "sconnor@example.com"
    Then I should see "sconnor@example.com" before "ja@hotmail.com"

  Scenario: Admin filters users by membership status
    Given I am on the "all users" page

    When I click the radio button with id "radio-membership-filter-all"
    And I click on t("search")
    Then I should see "sconnor@example.com"
    And I should see "luke@force.net"
    And I should see "ja@hotmail.com"

    When I click the radio button with id "radio-membership-filter-members"
    And I click on t("search")
    Then I should see "sconnor@example.com"
    And I should not see "luke@force.net"
    And I should not see "ja@hotmail.com"

    When I click the radio button with id "radio-membership-filter-not-members"
    And I click on t("search")
    Then I should see "luke@force.net"
    And I should see "ja@hotmail.com"
    And I should not see "sconnor@example.com"
