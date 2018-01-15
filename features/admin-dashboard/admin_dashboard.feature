Feature: Admin sees the dashboard with summary of important information

  As an admin
  So that I have a snapshot of important statistics
  And so I know of actions I must take
  Show me a dashboard when I log in with summaries and info that is important

  Background:

    Given the following users exists
      | email                            | admin | member |
      | new_1@bowwowwow.se               |       |        |
      | new_2@mutts.se                   |       |        |
      | new_3@mutts.se                   |       |        |
      | under_review_1@bowwowwow.se      |       |        |
      | under_review_2@mutts.se          |       |        |
      | under_review_3@mutts.se          |       |        |
      | under_review_4@mutts.se          |       |        |
      | waiting_for_applicant_1@mutts.se |       |        |
      | ready_for_review_1@mutts.se      |       |        |
      | ready_for_review_2@bowwowwow.se  |       |        |
      | member_1@mutts.se                |       | true   |
      | member_2@mutts.se                |       | true   |
      | member_3@mutts.se                |       | true   |
      | member_4@mutts.se                |       | true   |
      | member_5@mutts.se                |       | true   |
      | member_6@bowwowwow.se            |       | true   |
      | member_7@bowwowwow.se            |       | true   |
      | member_8@bowwowwow.se            |       | true   |
      | member_9@bowwowwow.se            |       | true   |
      | member_10@bowwowwow.se           |       | true   |
      | member_11@bowwowwow.se           |       | true   |
      | rejected_1@mutts.se              |       |        |
      | rejected_2@bowwowwow.se          |       |        |
      | admin@shf.se                     | true  |        |

    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | rehab        | physical rehabilitation         |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name        | company_number | email               | region    |
      | Bow Wow Wow | 2120000142     | hellow@bowwowwow.se | Stockholm |
      | Mutts R Us  | 5562252998     | voof@mutts.se       | Stockholm |

    And the following applications exist:
      | user_email                       | company_number | categories   | state                 |
      | new_1@bowwowwow.se               | 2120000142     | dog grooming | new                   |
      | new_2@mutts.se                   | 5562252998     | dog grooming | new                   |
      | new_3@mutts.se                   | 5562252998     | rehab        | new                   |
      | under_review_1@bowwowwow.se      | 2120000142     | dog grooming | under_review          |
      | under_review_2@mutts.se          | 5562252998     | dog grooming | under_review          |
      | under_review_3@mutts.se          | 5562252998     | dog grooming | under_review          |
      | under_review_4@mutts.se          | 5562252998     | dog grooming | under_review          |
      | waiting_for_applicant_1@mutts.se | 5562252998     | dog grooming | waiting_for_applicant |
      | ready_for_review_1@mutts.se      | 5562252998     | dog grooming | ready_for_review      |
      | ready_for_review_2@bowwowwow.se  | 2120000142     | dog grooming | ready_for_review      |
      | member_1@mutts.se                | 5562252998     | rehab        | accepted              |
      | member_2@mutts.se                | 5562252998     | dog grooming | accepted              |
      | member_3@mutts.se                | 5562252998     | dog grooming | accepted              |
      | member_4@mutts.se                | 5562252998     | dog grooming | accepted              |
      | member_5@mutts.se                | 5562252998     | dog grooming | accepted              |
      | member_6@bowwowwow.se            | 2120000142     | dog grooming | accepted              |
      | member_7@bowwowwow.se            | 2120000142     | dog grooming | accepted              |
      | member_8@bowwowwow.se            | 2120000142     | dog grooming | accepted              |
      | member_9@bowwowwow.se            | 2120000142     | dog grooming | accepted              |
      | member_10@bowwowwow.se           | 2120000142     | dog grooming | accepted              |
      | member_11@bowwowwow.se           | 2120000142     | dog grooming | accepted              |
      | rejected_1@mutts.se              | 5562252998     | rehab        | rejected              |
      | rejected_2@bowwowwow.se          | 2120000142     | rehab        | rejected              |


    And the following payments exist
      | user_email             | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member_1@mutts.se      | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | member_2@mutts.se      | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | member_3@mutts.se      | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | member_4@mutts.se      | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | member_5@mutts.se      | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | member_6@bowwowwow.se  | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | member_6@bowwowwow.se  | 2017-10-1  | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | member_7@bowwowwow.se  | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | member_8@bowwowwow.se  | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | member_9@bowwowwow.se  | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |


    Given I am logged in as "admin@shf.se"


  #Scenario: Admin can set date range for the recent summary numbers
  #Scenario: default date range for summary is the past 30 days


  @selenium
  Scenario: Admin sees the dashboard with summary info
    Given I am on the "admin dashboard" page
    Then I should see t("admin_only.dashboard.title")
    And I should see t("admin_only.dashboard.total_members", total_num_members: 11)
    And I should see t("admin_only.dashboard.recent_activity_section_title", recent_num_days: 7)
    And I should see t("activerecord.models.shf_application.other")
    And I should see "9 "
    And I should see t("admin_only.dashboard.payments")
    And I should see t("admin_only.dashboard.member_fee_payments", number_payments: 9)
    And I should see t("admin_only.dashboard.branding_fee_payments", number_payments: 1)
    And I should see t("admin_only.dashboard.current_items_section_title")
    And I should see "0 "
    And I should see t("admin_only.dashboard.open_apps_no_files")
    And I should see "2 "
    And I should see t("admin_only.dashboard.app_approved_no_payment")
    And I should see "1 "
    And I should see t("admin_only.dashboard.companies_no_branding_payment")
    And I should see "0 "
    And I should see t("admin_only.dashboard.companies_incomplete")

    #And I should see "Change timeframe:"

    # TODO how to test for the lines that have a formatted number, then a t('') phrase?

  # Summary:
  #   11 members
  #     new: 3, under_review: 4, waiting_for_applicant: 1, ready_for_review: 2, accepted: 11, rejected: 2
  #   In the past 7 days:
  #     Membership Applications:
  #       new: 3, under_review: 4, waiting_for_applicant: 1, ready_for_review: 2, accepted: 11, rejected: 2
  #     12 Successful payments:
  #       9 member fee payments
  #       1 branding fee payments
  # Current items of note:
  #   10 Open Applications with no files uploaded
  #   2 Applications approved but no membership payment yet
  #   1 companies Branding license fee not yet paid
  #   0 companies with information not yet complete
  #


  Scenario: Default timeframe displayed is 7 days

  Scenario: Change the timeframe displayed
  # when the timeframe option is changed:
  #  the number in the subtitle changes
  # the data is changed



#  Scenario: If there are no applications for a state, then a zero (0) is displayed instead of skipping it


#  Scenario: Admin sees financial transactions summary


#  Scenario: Admin sees list of companies that do not have branding fees paid


#  Scenario: Admin sees list of approved applicants that have not paid their member fees


#  Scenario: Admin sees applications that need action


#  Scenario: Admin sees schedule of upcoming application renewals


#  Scenario: Admin sees a list of companies that don't have complete information

