Feature: Show user account (details) information to a member

  As a user
  So that I know what information SHF has about me
  Show me my user account page

  PT:  https://www.pivotaltracker.com/story/show/140358959


  Proof of Membership and Company H-Branding Information: see separate features
  features/user_account/company_h_brand.feature
  features/user_account/proof_of_membership.feature

  Background:

    Given the date is set to "2018-06-06"
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                              | admin | membership_number | member | first_name | last_name      |
      | emma-member@example.com            |       | 1001              | true   | Emma       | IsAMember      |
      | lars-member@example.com            |       | 101               | true   |            |                |
      | admin@shf.se                       | true  |                   |        |            |                |

    And the following users have agreed to the Membership Ethical Guidelines:
    | email |
    | emma-member@example.com            |
    | lars-member@example.com            |

    And the following regions exist:
      | name         |
      | Stockholm    |

    And the following companies exist:
      | name                 | company_number | email               | region       |
      | Happy Mutts          | 5560360793     | woof@happymutts.com | Stockholm    |
      | Bowsers              | 2120000142     | bark@bowsers.com    | Stockholm |


    And the following applications exist:
      | user_email                         | contact_email              | company_number | state    |
      | lars-member@example.com            | lars-member@happymutts.com | 5560360793     | accepted |
      | emma-member@example.com            | emma-member@bowsers.com    | 2120000142     | accepted |


    And the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |
      | lars-member@example.com | 2018-05-05 | 2019-05-04  | member_fee   | betald | none    |


    And the following membership packets have been sent:
      | user_email              | date_sent  |
      | lars-member@example.com | 2018-05-06 |


  Scenario: User sees their full name and login email
    Given I am logged in as "emma-member@example.com"
    When I am on the "user account" page for "emma-member@example.com"
    Then I should see "Emma IsAMember"
    And I should see t("users.show_login_email_row_cols.email")
    And I should see "emma-member@example.com"



  # ======================
  # Membership Information

  # Is a member

  Scenario: Member sees their membership number
    Given I am logged in as "emma-member@example.com"
    When I am on the "user account" page for "emma-member@example.com"
    Then I should see t("users.show.membership_number")
    And I should see "1001"


  Scenario: Member sees their membership status (is a member)
    Given I am logged in as "emma-member@example.com"
    When I am on the "user account" page for "emma-member@example.com"
    Then I should see "Status"
    And I should see t("users.show.is_a_member")


  Scenario: Member sees the date their membership term is paid through
    Given I am logged in as "emma-member@example.com"
    When I am on the "user account" page for "emma-member@example.com"
    Then I should see t("users.show.term_paid_through")
    And the user is paid through "2018-12-31"



  # Proof of Membership and Company H-Branding Information: see separate features
