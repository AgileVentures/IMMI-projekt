Feature:

  As an admin
  I would like to search and sort users
  to find a particular user amoung many
  and to know which users are members and which are not

  Background:
    Given the following users exist
      | first_name | last_name | email                               | admin |
      | John       | Adams     | ja@hotmail.com                      | false |
      | Sarah      | Conors    | sconors@example.com                 | false |
      | Luke       | Skywalker | luke@force.net                      | false |
      | admin      | admin     | admin@sverigeshundforetagare.se     | true  |
    And the following applications exist:
      | user_email          | state                 | company_number |
      | ja@hotmail.com      | waiting_for_applicant | 0000000000     |
      | sconors@example.com | accepted              | 0000000000     |
      | luke@force.net      | rejected              | 0000000000     |
    And I am logged in as "admin@sverigeshundforetagare.se"

  Scenario: Admin searches for luke
    Given I am on the "users" page
    When I fill in t("users.search_form.profile_email") with "luke"
    And I click on t("search")
    Then I should see "luke@force.net"
    And I should not see "sconors@example.com"

  Scenario: Admin searches for @sverigeshundföretagare.se
    Given I am on the "users" page
    When I fill in t("users.search_form.profile_email") with "@sverigeshundföretagare.se"
    And I click on t("search")
    Then I should not see "admin@sverigeshundforetagare.se"
    And I should see t("users.index.no_search_results")

  Scenario: Admin sorts users by email
    Given I am on the "users" page
    When I click on t("users.users_list.email")
    Then I should see "luke@force.net" before "sconors@example.com"

  Scenario: Admin filters users by membership status
    Given I am on the "users" page

    When I select radio button t("users.search_form.all_users")
    And I click on t("search")
    Then I should see "sconors@example.com"
    And I should see "luke@force.net"
    And I should see "ja@hotmail.com"

    When I select radio button t("users.search_form.are_members")
    And I click on t("search")
    Then I should see "sconors@example.com"
    And I should not see "luke@force.net"
    And I should not see "ja@hotmail.com"

    When I select radio button t("users.search_form.are_not_members")
    And I click on t("search")
    Then I should see "luke@force.net"
    And I should see "ja@hotmail.com"
    And I should not see "sconors@example.com"
