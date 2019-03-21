Feature: Admin sees as many or few SHF Applications as they want (pagination)

  As an admin,
  so that I can manage membership applications,
  I want to see all membership applications

  Background:
    Given the following users exists
      | email         | admin | member    |
      | u1@mutts.com  |       | false     |
      | u2@mutts.com  |       | false     |
      | u3@mutts.com  |       | true      |
      | u4@mutts.com  |       | true      |
      | u5@mutts.com  |       | true      |
      | u6@mutts.com  |       | true      |
      | u7@mutts.com  |       | true      |
      | u8@mutts.com  |       | true      |
      | u9@mutts.com  |       | true      |
      | u10@mutts.com |       | true      |
      | u11@mutts.com |       | true      |
      | u12@mutts.com |       | true      |
      | u13@mutts.com |       | true      |
      | u14@mutts.com |       | true      |
      | u15@mutts.com |       | true      |
      | u16@mutts.com |       | true      |
      | u17@mutts.com |       | true      |
      | u18@mutts.com |       | true      |
      | u19@mutts.com |       | true      |
      | u20@mutts.com |       | true      |
      | u21@mutts.com |       | true      |
      | u22@mutts.com |       | true      |
      | u23@mutts.com |       | true      |
      | u24@mutts.com |       | true      |
      | u25@mutts.com |       | true      |
      | u26@mutts.com |       | true      |
      | u27@mutts.com |       | true      |
      | u28@mutts.com |       | true      |
      | admin@shf.se  | true  | false     |

    And the following applications exist:
      | user_email    | company_number | state                 |
      | u1@mutts.com  | 2120000142     | under_review          |
      | u2@mutts.com  | 2965790286     | waiting_for_applicant |
      | u3@mutts.com  | 2965790286     | under_review          |
      | u4@mutts.com  | 3609340140     | under_review          |
      | u5@mutts.com  | 4268582063     | under_review          |
      | u6@mutts.com  | 5560360793     | waiting_for_applicant |
      | u7@mutts.com  | 6112107039     | waiting_for_applicant |
      | u8@mutts.com  | 6222279082     | under_review          |
      | u9@mutts.com  | 6613265393     | under_review          |
      | u10@mutts.com | 6914762726     | under_review          |
      | u11@mutts.com | 7661057765     | under_review          |
      | u12@mutts.com | 7736362901     | under_review          |
      | u13@mutts.com | 8025085252     | waiting_for_applicant |
      | u14@mutts.com | 8028973322     | waiting_for_applicant |
      | u15@mutts.com | 8356502446     | under_review          |
      | u16@mutts.com | 8394317054     | under_review          |
      | u17@mutts.com | 8423893877     | under_review          |
      | u18@mutts.com | 8589182768     | waiting_for_applicant |
      | u19@mutts.com | 8616006592     | under_review          |
      | u20@mutts.com | 8728875504     | under_review          |
      | u21@mutts.com | 8764985894     | under_review          |
      | u22@mutts.com | 8822107739     | under_review          |
      | u23@mutts.com | 8909248752     | under_review          |
      | u24@mutts.com | 9074668568     | under_review          |
      | u25@mutts.com | 9243957975     | under_review          |
      | u26@mutts.com | 9267816362     | waiting_for_applicant |
      | u27@mutts.com | 9360289459     | under_review          |
      | u28@mutts.com | 9475077674     | under_review          |



  @selenium
  Scenario: Pagination: default is All, can set to just 10 items
    Given I am logged in as "admin@shf.se"
    And I am on the "membership applications" page
    And I hide the search form
    Then "items_count" should have "All" selected
    And I select "10" in select list "items_count"
    Then "items_count" should have "10" selected
    # prevents getting the element not clickable at that position error in Chrome
    And I scroll so the top of the list of companies is visible
    When I click on t("shf_applications.index.org_nr")
    And I should see "6222279082" before "6613265393"
    And I should see "6613265393" before "6914762726"
    Then I click on t("will_paginate.next_label") link
    And I should see "7661057765"
    And I should see "8728875504"
    And I should not see "6914762726"
    And I should not see "8764985894"
    Then I click on t("will_paginate.next_label") link
    And I should see "8764985894"
    And I should not see "8728875504"

  @selenium
  Scenario: Pagination: Set number of items per page to various choices
    Given I am logged in as "admin@shf.se"
    And I am on the "membership applications" page
    And I hide the search form
    Then "items_count" should have "All" selected
    And I should see "28" applications
    And I should see "2120000142"
    And I should see "9475077674"
    Then I select "25" in select list "items_count"
    And I should see "25" applications
    And "items_count" should have "25" selected
    And I should see "9243957975"
    And I should not see "9267816362"
    Then I select "10" in select list "items_count"
    And I should see "10" applications
    And I should see "6914762726"
    And I should not see "7661057765"
