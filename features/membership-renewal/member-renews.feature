Feature: Member renews their membership

  As a member
  So that I can continue my membership for another term
  I must be able to renew


  Background:

    Given the date is set to "2018-06-06"
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists


    Given the following users exist:
      | email                                           | admin | membership_status | membership_number | member | first_name   | last_name                   |
      | member-all-reqs-met@example.com                 |       | current_member    | 101               | true   | Member       | All-Requirements-met        |
      | member-in-grace-period-all-reqs-met@example.com |       | current_member    | 102               | true   | LapsedMember | All-Requirements-met        |
      | member-agreed-before-current-start@example.com  |       | current_member    | 103               | true   | Member       | Agreed-Before-Current-Start |
      | member-agreed-on-current-start@example.com      |       | current_member    | 104               | true   | Member       | Agreed-On-Current-Start     |
      | member-agreed-after-current-start@example.com   |       | current_member    | 105               | true   | Member       | Agreed-After-Current-Start  |
      | admin@shf.se                                    | true  |                   |                   |        |              |                             |


    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name    | company_number | email            | region    |
      | Bowsers | 2120000142     | bark@bowsers.com | Stockholm |


    And the following business categories exist
      | name     | description   |
      | Grooming | grooming dogs |


    And the following applications exist:
      | user_email                                      | contact_email                    | company_number | state    | categories |
      | member-all-reqs-met@example.com                 | emma-member@bowsers.com          | 2120000142     | accepted | Grooming   |
      | member-in-grace-period-all-reqs-met@example.com | lars-member@bowsers.com          | 2120000142     | accepted | Grooming   |
      | member-agreed-before-current-start@example.com  | member-agreed-before@bowsers.com | 2120000142     | accepted | Grooming   |


    And the following payments exist
      | user_email                                      | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member-all-reqs-met@example.com                 | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | member-all-reqs-met@example.com                 | 2018-01-1  | 2018-12-31  | branding_fee | betald | none    | 2120000142     |
      | member-in-grace-period-all-reqs-met@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | member-agreed-before-current-start@example.com  | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |


    And these files have been uploaded:
      | user_email                                      | file name | description                               |
      | member-all-reqs-met@example.com                 | image.png | Image of a class completion certification |
      | member-in-grace-period-all-reqs-met@example.com | image.png | Image of a class completion certification |
      | member-agreed-before-current-start@example.com  | image.png | Image of a class completion certification |


    And the following memberships exist:
      | email                                           | first_day | last_day   |
      | member-all-reqs-met@example.com                 | 2018-01-1 | 2018-12-31 |
      | member-in-grace-period-all-reqs-met@example.com | 2018-01-1 | 2018-12-31 |
      | member-agreed-before-current-start@example.com  | 2018-01-1 | 2018-12-31 |


    And the following users have agreed to the Membership Ethical Guidelines:
      | email                                           | date agreed to |
      | member-all-reqs-met@example.com                 |                |
      | member-in-grace-period-all-reqs-met@example.com |                |
      | member-agreed-before-current-start@example.com  | 2017-12-31     |

    # ---------------------------------------------------------------------------------------------


  Scenario Outline: Renews on days around expiration (all requirements met)
    Given the date is set to "<the_date>"
    And I am logged in as "member-all-reqs-met@example.com"
    And I am on the "user account" page
    Then I should see <renewal_title>
    And I should see <renewal_instructions>
    And the link button t("users.show.pay_membership") should not be disabled
    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And the user is paid through "<new_paid_thru_date>"

    Scenarios:
      | the_date   | new_paid_thru_date | renewal_title                            | renewal_instructions                       |
      | 2018-12-30 | 2019-12-31         | t("users.renewal.title_time_to_renew")   | t("users.renewal.instructions")            |
      | 2018-12-31 | 2019-12-31         | t("users.renewal.title_time_to_renew")   | t("users.renewal.instructions")            |
      | 2019-01-01 | 2019-12-31         | t("users.renewal.title_renewal_overdue") | t("users.renewal.renewal_overdue_warning") |
      | 2019-01-05 | 2020-01-04         | t("users.renewal.title_renewal_overdue") | t("users.renewal.renewal_overdue_warning") |


  Scenario: Membership in grace period; all renewal requirements met and member pays
    Given the date is set to "2019-01-05"
    And I am logged in as "member-in-grace-period-all-reqs-met@example.com"
    And I am on the "user account" page
    Then I should see t("users.renewal.title_renewal_overdue")
    And I should see t("users.renewal.renewal_overdue_warning")
    And the link button t("users.show.pay_membership") should not be disabled
    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And the user is paid through "2020-01-04"


  Scenario: Must agree to Ethical Guidelines again: last agreed to them 1 day before start of current membership term
    Given the date is set to "2019-01-05"
    And I am logged in as "member-agreed-before-current-start@example.com"
    And I am on the "user account" page
    Then I should see t("users.renewal.title_renewal_overdue")
    And I should see t("users.renewal.renewal_overdue_warning")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled
