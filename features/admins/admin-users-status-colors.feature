Feature: Membership status is color-coded for admin's list of all users

  As an admin
  So that I can quickly see the status of users,
  Color-code and otherwise style the membership status
  On the 'all users' page


  Background:
    Given the App Configuration is not mocked and is seeded
    Given the Membership Ethical Guidelines Master Checklist exists
    And the grace period is 600 days

    Given the following users exist:
      | email                         | admin | membership_status | membership_number | member |
      | current-member@example.com    |       | current_member    | 100               | true   |
      | expires-soon-1@example.com    |       | current_member    | 102               | true   |
      | expires-soon-2@example.com    |       | current_member    | 103               | true   |
      | in-grace-period-1@example.com |       | in_grace_period   | 104               | false  |
      | in-grace-period-2@example.com |       | in_grace_period   | 105               | false  |
      | in-grace-period-3@example.com |       | in_grace_period   | 106               | false  |
      | former-member-1@example.com   |       | former_member     | 107               | false  |
      | former-member-2@example.com   |       | former_member     | 108               | false  |
      | former-member-3@example.com   |       | former_member     | 109               | false  |
      | former-member-4@example.com   |       | former_member     | 110               | false  |
      | not-a-member-1@example.com    |       |                   |                   |        |
      | not-a-member-2@example.com    |       |                   |                   |        |
      | not-a-member-3@example.com    |       |                   |                   |        |
      | not-a-member-4@example.com    |       |                   |                   |        |
      | not-a-member-5@example.com    |       |                   |                   |        |
      | admin@shf.se                  | true  |                   |                   |        |

    And the following companies exist:
      | name        | company_number | email               |
      | Happy Mutts | 5560360793     | woof@happymutts.com |

    And the following applications exist:
      | user_email                    | contact_email                 | company_number | state    |
      | current-member@example.com    | current-member@example.com    | 5560360793     | accepted |
      | expires-soon-1@example.com    | expires-soon-1@example.com    | 5560360793     | accepted |
      | expires-soon-2@example.com    | expires-soon-2@example.com    | 5560360793     | accepted |
      | in-grace-period-1@example.com | in-grace-period-1@example.com | 5560360793     | accepted |
      | former-member-1@example.com   | former-member-1@example.com   | 5560360793     | accepted |
      | not-a-member-1@example.com    | not-a-member-1@example.com    | 5560360793     | rejected |


    And the following users have agreed to the Membership Ethical Guidelines:
      | email                         |
      | current-member@example.com    |
      | expires-soon-1@example.com    |
      | expires-soon-2@example.com    |
      | in-grace-period-1@example.com |
      | in-grace-period-2@example.com |
      | in-grace-period-3@example.com |
      | former-member-1@example.com   |
      | former-member-2@example.com   |
      | former-member-3@example.com   |
      | former-member-4@example.com   |

    And the following payments exist
      | user_email                    | start_date | expire_date | payment_type | status |
      | current-member@example.com    | 2021-01-01 | 2021-12-31  | member_fee   | betald |
      | expires-soon-1@example.com    | 2021-01-01 | 2021-5-31   | member_fee   | betald |
      | expires-soon-2@example.com    | 2021-01-01 | 2021-5-31   | member_fee   | betald |
      | in-grace-period-1@example.com | 2020-01-01 | 2021-12-31  | member_fee   | betald |
      | in-grace-period-2@example.com | 2020-01-01 | 2021-12-31  | member_fee   | betald |
      | in-grace-period-3@example.com | 2020-01-01 | 2021-12-31  | member_fee   | betald |
      | former-member-1@example.com   | 2017-01-01 | 2018-12-31  | member_fee   | betald |
      | former-member-2@example.com   | 2017-01-01 | 2018-12-31  | member_fee   | betald |
      | former-member-3@example.com   | 2017-01-01 | 2018-12-31  | member_fee   | betald |
      | former-member-4@example.com   | 2017-01-01 | 2018-12-31  | member_fee   | betald |

    And the following memberships exist:
      | email                         | first_day  | last_day   |
      | current-member@example.com    | 2021-01-01 | 2021-12-31 |
      | expires-soon-1@example.com    | 2021-01-01 | 2021-05-31 |
      | expires-soon-2@example.com    | 2021-01-01 | 2021-05-31 |
      | in-grace-period-1@example.com | 2020-01-01 | 2021-12-31 |
      | in-grace-period-2@example.com | 2020-01-01 | 2021-12-31 |
      | in-grace-period-3@example.com | 2020-01-01 | 2021-12-31 |
      | former-member-1@example.com   | 2017-01-01 | 2018-12-31 |
      | former-member-2@example.com   | 2017-01-01 | 2018-12-31 |
      | former-member-3@example.com   | 2017-01-01 | 2018-12-31 |
      | former-member-4@example.com   | 2017-01-01 | 2018-12-31 |


    And I am logged in as "admin@shf.se"
    And the date is set to "2021-06-06"

  # -----------------------------------------------------------------------------------------------

  Scenario: Legend is shown at the top
    Given I am on the "all users" page
    Then I should see css class "legend" 1 times


  @selenium
  Scenario: The membership status is used as the CSS class for each user's membership status and last day (if there is a last day)
    Given I am on the "all users" page
    When I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see 16 users

    And css class "current-member" should appear 2 times in the users table
    And css class "expires-soon" should appear 4 times in the users table
    And css class "in-grace-period" should appear 6 times in the users table
    And css class "former-member" should appear 8 times in the users table

    # Note there is no last day for those that are not-a-member, so the css style only applies to the membership_status (once per user)
    And css class "not-a-member" should appear 6 times in the users table
