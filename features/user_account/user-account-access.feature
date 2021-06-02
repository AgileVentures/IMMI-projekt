Feature: Who can and cannot see a user account page

  Background:

    Given the date is set to "2018-06-06"
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                   | admin | membership_status | membership_number | member | first_name | last_name  |
      | emma-member@example.com |       | current_member    | 1001              | true   | Emma       | IsAMember  |
      | lars-member@example.com |       | current_member    | 101               | true   |            |            |
      | admin@shf.se            | true  |                   |                   |        |            |            |
      | applied@example.com     |       | not_a_member      |                   | false  | Applied    | NotAMember |


    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    And the following companies exist:
      | name                 | company_number | email               | region       |
      | Happy Mutts          | 5560360793     | woof@happymutts.com | Stockholm    |
      | Bowsers              | 2120000142     | bark@bowsers.com    | Västerbotten |
      | No More Snarky Barky | 6914762726     | bark@snarky.com     | Västerbotten |
      | Voof                 | 7736362901     | voof@voof.com       | Stockholm    |


    And the following applications exist:
      | user_email              | contact_email              | company_number | state    |
      | lars-member@example.com | lars-member@happymutts.com | 5560360793     | accepted |
      | emma-member@example.com | emma-member@bowsers.com    | 2120000142     | accepted |
      | applied@example.com     | applied@example.com        | 2120000142     | new      |


    And the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |
      | lars-member@example.com | 2018-05-05 | 2019-05-04  | member_fee   | betald | none    |


    And the following memberships exist:
      | email                   | first_day  | last_day   |
      | emma-member@example.com | 2018-01-1  | 2018-12-31 |
      | lars-member@example.com | 2018-05-05 | 2019-05-04 |

    And the following membership packets have been sent:
      | user_email              | date_sent  |
      | lars-member@example.com | 2018-05-06 |


  # ======================================
  # Who can and cannot see the information

  Scenario: a visitor cannot see a user page
    Given I am logged out
    When I am on the "user account" page for "lars-member@example.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: user cannot see the user page for another user
    Given I am logged in as "applied@example.com"
    When I am on the "user account" page for "lars-member@example.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: a user can see their own user page
    Given I am logged in as "applied@example.com"
    When I am on the "user account" page for "applied@example.com"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see "applied@example.com"


  Scenario: member cannot see the user page for another user
    Given I am logged in as "lars-member@example.com"
    When I am on the "user account" page for "emma-member@example.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: a member can see their own user page
    Given I am logged in as "lars-member@example.com"
    When I am on the "user account" page for "lars-member@example.com"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see t("users.show_login_email_row_cols.email")
    And I should see "lars-member@example.com"
    And I should see t("users.show.membership_number")


