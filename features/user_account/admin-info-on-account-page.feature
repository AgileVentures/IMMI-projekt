Feature: Admin sees additional info on User Account pages

  As an admin
  So that I can see why an account has the current status it does
  and so I can see important historical information about the account
  and so I can see what actions I have or need to take for the account
  Show me more information about the account


  Background:

    Given the date is set to "2018-06-06"
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists


    Given the following users exist:
      | email                   | admin | membership_number | member | first_name | last_name |
      | emma-member@example.com |       | 1001              | true   | Emma       | IsAMember |
      | lars-member@example.com |       | 101               | true   |            |           |
      | admin@shf.se            | true  |                   |        |            |           |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                   |
      | emma-member@example.com |
      | lars-member@example.com |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name        | company_number | email               | region    |
      | Happy Mutts | 5560360793     | woof@happymutts.com | Stockholm |
      | Bowsers     | 2120000142     | bark@bowsers.com    | Stockholm |


    And the following business categories exist
      | name         | description   | subcategories          |
      | dog grooming | grooming dogs | light trim, custom cut |


    And the following applications exist:
      | user_email              | contact_email              | company_number | state    | categories   |
      | lars-member@example.com | lars-member@happymutts.com | 5560360793     | accepted | dog grooming |
      | emma-member@example.com | emma-member@bowsers.com    | 2120000142     | accepted | dog grooming |


    And the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | branding_fee   | betald | none    |
      | lars-member@example.com | 2018-05-05 | 2019-05-04  | member_fee   | betald | none    |


    And the following membership packets have been sent:
      | user_email              | date_sent  |
      | lars-member@example.com | 2018-05-06 |

    And I am logged in as "admin@shf.se"

    # ---------------------------------------------------------------------------------------

  Scenario: Admin sees payments
    When I am on the "user account" page for "emma-member@example.com"
    Then I should see t("payor.term_status.admin_user_payments_title")
    And I should see t("payments.payments_list.payment_date")
    And I should see t("payments.payments_list.type")
    And I should see t("payments.payments_list.status")
    And I should see t("payments.payments_list.start_date")
    And I should see t("payments.payments_list.end_date")
    And I should see t("payments.payments_list.notes")
    And I should see t("payments.payments_list.hips_id")

    And I should see "betald" in the row for "member_fee"
    And I should see "2018-01-01" in the row for "member_fee"
    And I should see "2018-12-31" in the row for "member_fee"
    And I should see "betald" in the row for "branding_fee"
    And I should see "2018-01-01" in the row for "branding_fee"
    And I should see "2018-12-31" in the row for "branding_fee"
