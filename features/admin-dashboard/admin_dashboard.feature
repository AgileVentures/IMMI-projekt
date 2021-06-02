Feature: Admin sees the dashboard with summary of important information

  As an admin
  So that I have a snapshot of important statistics
  And so I know of actions I must take
  Show me a dashboard when I log in with summaries and info that is important

  Background:
    Given the date is set to "2020-01-01"

    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                                         | admin | member | membership_status | agreed_to_membership_guidelines |
      | new_1@bowwowwow.se                            |       |        |                   |                                 |
      | new_2@mutts.se                                |       |        |                   |                                 |
      | new_3@mutts.se                                |       |        |                   |                                 |
      | under_review_1@bowwowwow.se                   |       |        |                   |                                 |
      | under_review_2@mutts.se                       |       |        |                   |                                 |
      | under_review_3@mutts.se                       |       |        |                   |                                 |
      | under_review_4@mutts.se                       |       |        |                   |                                 |
      | waiting_for_applicant_1@mutts.se              |       |        |                   |                                 |
      | ready_for_review_1@mutts.se                   |       |        |                   |                                 |
      | ready_for_review_2@bowwowwow.se               |       |        |                   |                                 |
      | member_1@currentco1.se                        |       | true   | current_member    | true                            |
      | member_2@currentco2.se                        |       | true   | current_member    | true                            |
      | member_3@currentco3.se                        |       | true   | current_member    | true                            |
      | member_4@currentco4.se                        |       | true   | current_member    | true                            |
      | member_5@mutts.se                             |       | true   | current_member    | true                            |
      | member_6@bowwowwow.se                         |       | true   | current_member    | true                            |
      | member_7@bowwowwow.se                         |       | true   | current_member    | true                            |
      | member_8@bowwowwow.se                         |       | true   | current_member    | true                            |
      | member_9@bowwowwow.se                         |       | true   | current_member    | true                            |
      | approved_applicant_10_no_payment@bowwowwow.se |       | false  |                   |                                 |
      | approved_applicant_11_no_payment@bowwowwow.se |       | false  |                   |                                 |
      | approved_applicant_12_no_payment@bowwowwow.se |       | false  |                   |                                 |
      | rejected_1@mutts.se                           |       |        |                   |                                 |
      | rejected_2@bowwowwow.se                       |       |        |                   |                                 |
      | admin@shf.se                                  | true  |        |                   |                                 |

    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | rehab        | physical rehabilitation         |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name               | company_number | email               | region    |
      | Bow Wow Wow unpaid | 2120000142     | hellow@bowwowwow.se | Stockholm |
      | Mutts R Us unpaid  | 5562252998     | voof@mutts.se       | Stockholm |
      | Current Co 1       | 2907071654     | voof@mutts.se       | Stockholm |
      | Current Co 2       | 7546905063     | voof@mutts.se       | Stockholm |
      | Current Co 3       | 4240295990     | voof@mutts.se       | Stockholm |
      | Current Co 4       | 6128168348     | voof@mutts.se       | Stockholm |

    And the following applications exist:
      | user_email                                    | company_number | categories   | state                 | uploaded file names |
      | new_1@bowwowwow.se                            | 2120000142     | dog grooming | new                   | diploma.pdf         |
      | new_2@mutts.se                                | 5562252998     | dog grooming | new                   | diploma.pdf         |
      | new_3@mutts.se                                | 5562252998     | rehab        | new                   | diploma.pdf         |
      | under_review_1@bowwowwow.se                   | 2120000142     | dog grooming | under_review          | diploma.pdf         |
      | under_review_2@mutts.se                       | 5562252998     | dog grooming | under_review          | diploma.pdf         |
      | under_review_3@mutts.se                       | 5562252998     | dog grooming | under_review          | diploma.pdf         |
      | under_review_4@mutts.se                       | 5562252998     | dog grooming | under_review          | diploma.pdf         |
      | waiting_for_applicant_1@mutts.se              | 5562252998     | dog grooming | waiting_for_applicant |                     |
      | ready_for_review_1@mutts.se                   | 5562252998     | dog grooming | ready_for_review      | diploma.pdf         |
      | ready_for_review_2@bowwowwow.se               | 2120000142     | dog grooming | ready_for_review      | diploma.pdf         |
      | member_1@currentco1.se                        | 2907071654     | rehab        | accepted              | diploma.pdf         |
      | member_2@currentco2.se                        | 7546905063     | dog grooming | accepted              | diploma.pdf         |
      | member_3@currentco3.se                        | 4240295990     | dog grooming | accepted              | diploma.pdf         |
      | member_4@currentco4.se                        | 6128168348     | dog grooming | accepted              | diploma.pdf         |
      | member_5@mutts.se                             | 5562252998     | dog grooming | accepted              | diploma.pdf         |
      | member_6@bowwowwow.se                         | 2120000142     | dog grooming | accepted              | diploma.pdf         |
      | member_7@bowwowwow.se                         | 2120000142     | dog grooming | accepted              | diploma.pdf         |
      | member_8@bowwowwow.se                         | 2120000142     | dog grooming | accepted              | diploma.pdf         |
      | member_9@bowwowwow.se                         | 2120000142     | dog grooming | accepted              | diploma.pdf         |
      | approved_applicant_10_no_payment@bowwowwow.se | 2120000142     | dog grooming | accepted              | diploma.pdf         |
      | approved_applicant_11_no_payment@bowwowwow.se | 2120000142     | dog grooming | accepted              | diploma.pdf         |
      | approved_applicant_12_no_payment@bowwowwow.se | 2120000142     | dog grooming | accepted              | diploma.pdf         |
      | rejected_1@mutts.se                           | 5562252998     | rehab        | rejected              | diploma.pdf         |
      | rejected_2@bowwowwow.se                       | 2120000142     | rehab        | rejected              | diploma.pdf         |


    And the following payments exist
      | user_email             | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member_1@currentco1.se | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | member_1@currentco1.se | 2020-01-01 | 2020-12-31  | branding_fee | betald | none    | 2907071654     |
      | member_2@currentco2.se | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | member_2@currentco2.se | 2020-01-01 | 2020-12-31  | branding_fee | betald | none    | 7546905063     |
      | member_3@currentco3.se | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | member_3@currentco3.se | 2020-01-01 | 2020-12-31  | branding_fee | betald | none    | 4240295990     |
      | member_4@currentco4.se | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | member_4@currentco4.se | 2020-01-01 | 2020-12-31  | branding_fee | betald | none    | 6128168348     |
      | member_5@mutts.se      | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | member_6@bowwowwow.se  | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | member_6@bowwowwow.se  | 2020-01-01 | 2020-12-31  | branding_fee | betald | none    |                |
      | member_7@bowwowwow.se  | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | member_8@bowwowwow.se  | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | member_9@bowwowwow.se  | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |

    And the following memberships exist:
      | email                  | first_day  | last_day   |
      | member_1@currentco1.se | 2020-01-01 | 2020-12-31 |
      | member_2@currentco2.se | 2020-01-01 | 2020-12-31 |
      | member_3@currentco3.se | 2020-01-01 | 2020-12-31 |
      | member_4@currentco4.se | 2020-01-01 | 2020-12-31 |
      | member_5@mutts.se      | 2020-01-01 | 2020-12-31 |
      | member_6@bowwowwow.se  | 2020-01-01 | 2020-12-31 |
      | member_7@bowwowwow.se  | 2020-01-01 | 2020-12-31 |
      | member_8@bowwowwow.se  | 2020-01-01 | 2020-12-31 |
      | member_9@bowwowwow.se  | 2020-01-01 | 2020-12-31 |


    Given I am logged in as "admin@shf.se"
    Given the date is set to "2020-01-04"

  # ------------------------------------------------------------------------------------------------


  #Scenario: Admin can set date range for the recent summary numbers
  #Scenario: default date range for summary is the past 30 days


  # TODO really test if the the right values are with the right text; perhaps send the number to the t('')
  # TODO how to test for the lines that have a formatted number, then a t('') phrase?

  @selenium @admin_dashboard
  Scenario: Admin sees the dashboard with summary info
    Given I am on the "admin dashboard" page
    Then I should see t("admin_only.dashboard.title")

    # TODO: for some reason the div for the 'current' tab doesn't appear at first. Must click on something else then come back to that tab.
    When I click on t("admin_only.dashboard.tabs.activity.tab-title")
    And I click on t("admin_only.dashboard.tabs.current.tab-title")
    Then I should see t("admin_only.dashboard.tabs.current.title")
    # Expected values:
    # 1  applications with no files uploaded
    # 3  approved applications but no membership payment yet
    # 2  companies with no branding license/H-markt payment
    # 0 companies with incomplete information
    # 9 current members
    # 4 current companies
    #
    # Summary:
    # Current items of note:
    #   1 Open Applications with no files uploaded
    #   3 Applications approved but no membership payment yet
    #   2 companies Branding license fee not yet paid
    #   0 companies with information not yet complete
    #
    #   9 Current members
    #   4 Current companies
    #
    #   In the past 7 days:
    #     3 New Membership Applications
    #     Membership Applications:
    #       new: 3, under_review: 4, waiting_for_applicant: 1, ready_for_review: 2, accepted: 12, rejected: 2, destroyed: 0
    #     14 Successful payments:
    #       9 member fee payments
    #       5 branding fee payments
    #
    #   Membership Applications:
    #     new: 3, under_review: 4, waiting_for_applicant: 1, ready_for_review: 2, accepted: 12, rejected: 2
    #
    And I should see "1 "
    And I should see t("admin_only.dashboard.tabs.current.open_apps_no_files")
    And I should see "3 "
    And I should see t("admin_only.dashboard.tabs.current.app_approved_no_payment")
    And I should see "2 "
    And I should see t("admin_only.dashboard.tabs.current.companies_no_branding_payment")
    And I should see "0 "
    And I should see t("admin_only.dashboard.tabs.current.companies_incomplete")

    And I should see "9 "
    And I should see t("admin_only.dashboard.tabs.current.current_members")
    And I should see "4 "
    And I should see t("admin_only.dashboard.tabs.current.current_companies")

    When I click on t("admin_only.dashboard.tabs.activity.tab-title")
    Then I should see t("admin_only.dashboard.tabs.activity.title", recent_num_days: 7)
    And I should see t("activerecord.models.shf_application.other")
    And I should see "9 "
    And I should see t("admin_only.dashboard.tabs.activity.payments")
    And I should see t("admin_only.dashboard.tabs.activity.member_fee_payments", number_payments: 9)
    And I should see t("admin_only.dashboard.tabs.activity.branding_fee_payments", number_payments: 5)

    When I click on the second t("admin_only.dashboard.tabs.applications.tab-title") link
    # section title:
    Then I should see t("admin_only.dashboard.tabs.applications.title")

    When I click on the second t("admin_only.dashboard.tabs.users.tab-title") link
    # section title:
    Then I should see t("admin_only.dashboard.tabs.users.title")

    When I click on t("admin_only.dashboard.tabs.members.tab-title")
    Then I should see t("admin_only.dashboard.tabs.members.title")
    And I should see t("admin_only.dashboard.tabs.members.total_members", total_num_members: 9)

    When I click on t("admin_only.dashboard.tabs.payments_membership.tab-title")
    # section title:
    Then I should see t("admin_only.dashboard.tabs.payments_membership.title")

    When I click on t("admin_only.dashboard.tabs.payments_h_branding.tab-title")
    # section title:
    Then I should see t("admin_only.dashboard.tabs.payments_h_branding.title")


    #And I should see "Change timeframe:"




#  @admin_dashboard
#  Scenario: Default timeframe displayed is 7 days


#  @admin_dashboard
#  Scenario: Change the timeframe displayed
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

