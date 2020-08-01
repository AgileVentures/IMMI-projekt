Feature: Membership address get emails when a member has been unpaid for > 6 months

  As a nightly task,
  so that admins can check to see if lapsed members are still using the H-markt image but shouldn't be,
  assuming that anyone that still hasn't paid after 6 months is not going to pay for membership,
  Send an email to the membership address (not the admins!) with all members that are unpaid for 6 months.

  Timing for the task can be any valid Timing (e.g. every day, on a day of the month, etc.)


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                          | admin | member |
      | exp_may_31_01@mutts.se         |       | true   |
      | exp_may_31_02@mutts.se         |       | true   |
      | exp_jun_2_01@mutts.se          |       | true   |
      | exp_jun_12_01@mutts.se         |       | true   |
      | not_a_member_new_app@mutts.se  |       | false  |
      | not_a_member_rejected@mutts.se |       | false  |
      | admin_1@shf.se                 | true  |        |
      | admin_2@shf.se                 | true  |        |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name       | company_number | email         | region    |
      | Mutts R Us | 5562252998     | voof@mutts.se | Stockholm |


    And the following applications exist:
      | user_email                     | company_number | categories | state    |
      | exp_may_31_01@mutts.se         | 5562252998     | rehab      | accepted |
      | exp_may_31_02@mutts.se         | 5562252998     | rehab      | accepted |
      | exp_jun_2_01@mutts.se          | 5562252998     | rehab      | accepted |
      | exp_jun_12_01@mutts.se         | 5562252998     | rehab      | accepted |
      | not_a_member_new_app@mutts.se  | 5562252998     | rehab      | new      |
      | not_a_member_rejected@mutts.se | 5562252998     | rehab      | rejected |


    And the following payments exist
      | user_email             | start_date | expire_date | payment_type | status | hips_id | company_number |
      | exp_may_31_01@mutts.se | 2017-06-01 | 2018-05-31  | member_fee   | betald | none    |                |
      | exp_may_31_02@mutts.se | 2017-06-01 | 2018-05-31  | member_fee   | betald | none    |                |
      | exp_jun_2_01@mutts.se  | 2017-07-03 | 2018-07-02  | member_fee   | betald | none    |                |
      | exp_jun_12_01@mutts.se | 2017-07-13 | 2018-07-12  | member_fee   | betald | none    |                |


  @condition
  Scenario Outline: Timing is every day: members checked every day and alert sent if needed
    Given there is a condition with class_name "MemberUnpaidOver6MonthsAlert" and timing "every_day"
    And the date is set to <today>
    And the process_condition task sends "condition_response" to the "MemberUnpaidOver6MonthsAlert" class
    Then "membership@example.org" should receive <emails_sent> email
    And "admin_1@shf.se" should receive no email
    And "admin_2@shf.se" should receive no email
    And "exp_may_31_01@mutts.se" should receive no email
    And "exp_may_31_02@mutts.se" should receive no email
    And "exp_jun_2_01@mutts.se" should receive no email
    And "exp_jun_12_01@mutts.se" should receive no email
    And "not_a_member_new_app@mutts.se" should receive no email
    And "not_a_member_rejected@mutts.se" should receive no email

    Scenarios:
      | today        | emails_sent |
      | "2018-11-29" | no           |
      | "2018-11-30" | no           |
      | "2018-12-01" | an           |
      | "2019-1-01"  | an           |
      | "2019-1-11"  | an           |
      | "2019-1-12"  | an           |


  @condition
  Scenario Outline: Timing set to 1st and 15th of the month
    Given there is a condition with class_name "MemberUnpaidOver6MonthsAlert" and timing "day_of_month"
    And the condition has the days of the month set to [1, 15]
    And the date is set to <today>
    And the process_condition task sends "condition_response" to the "MemberUnpaidOver6MonthsAlert" class
    Then "membership@example.org" should receive <emails_sent> email
    And "admin_1@shf.se" should receive no email
    And "admin_2@shf.se" should receive no email
    And "exp_may_31_01@mutts.se" should receive no email
    And "exp_may_31_02@mutts.se" should receive no email
    And "exp_jun_2_01@mutts.se" should receive no email
    And "exp_jun_12_01@mutts.se" should receive no email
    And "not_a_member_new_app@mutts.se" should receive no email
    And "not_a_member_rejected@mutts.se" should receive no email

    Scenarios:
      | today        | emails_sent |
      | "2018-12-31" | no           |
      | "2019-1-01"  | an           |
      | "2019-1-02"  | no           |
      | "2019-1-03"  | no           |
      | "2019-1-04"  | no           |
      | "2019-1-05"  | no           |
      | "2019-1-06"  | no           |
      | "2019-1-07"  | no           |
      | "2019-1-08"  | no           |
      | "2019-1-09"  | no           |
      | "2019-1-10"  | no           |
      | "2019-1-11"  | no           |
      | "2019-1-12"  | no           |
      | "2019-1-13"  | no           |
      | "2019-1-14"  | no           |
      | "2019-1-15"  | an           |
      | "2019-1-16"  | no           |
      | "2019-1-17"  | no           |
      | "2019-1-18"  | no           |
      | "2019-1-19"  | no           |
      | "2019-1-20"  | no           |
      | "2019-1-21"  | no           |
      | "2019-1-22"  | no           |
      | "2019-1-23"  | no           |
      | "2019-1-24"  | no           |
      | "2019-1-25"  | no           |
      | "2019-1-26"  | no           |
      | "2019-1-27"  | no           |
      | "2019-1-28"  | no           |
      | "2019-1-29"  | no           |
      | "2019-1-30"  | no           |
      | "2019-1-31"  | no           |
      | "2019-2-01"  | an           |
      | "2019-2-02"  | no           |
      | "2019-2-03"  | no           |
      | "2019-2-04"  | no           |
      | "2019-2-05"  | no           |
      | "2019-2-06"  | no           |
      | "2019-2-07"  | no           |
      | "2019-2-08"  | no           |
      | "2019-2-09"  | no           |
      | "2019-2-10"  | no           |
      | "2019-2-11"  | no           |
      | "2019-2-12"  | no           |
      | "2019-2-13"  | no           |
      | "2019-2-14"  | no           |
      | "2019-2-15"  | an           |
      | "2019-2-16"  | no           |
      | "2019-2-17"  | no           |
      | "2019-2-18"  | no           |
      | "2019-3-01"  | an           |
      | "2019-3-15"  | an           |
