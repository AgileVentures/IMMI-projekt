Feature: Admin sees as many or few SHF Applications as they want (pagination)

  As an admin,
  so that I can manage membership applications,
  I want to see all membership applications

  Background:
    Given the following users exists
      | email             | admin | member    |
      | emma@random.com   |       | false     |
      | hans@random.com   |       | false     |
      | nils@random.com   |       | true      |
      | bob@barkybobs.com |       | true      |
      | admin@shf.se      | true  | false     |

    And the following applications exist:
      | user_email        | company_number | state                 |
      | hans@random.com   | 2120000142     | under_review          |
      | emma@random.com   | 2965790286     | waiting_for_applicant |
      | nils@random.com   | 2965790286     | under_review          |
      | hans@random.com   | 3609340140     | under_review          |
      | bob@barkybobs.com | 4268582063     | under_review          |
      | emma@random.com   | 5560360793     | waiting_for_applicant |
      | emma@random.com   | 6112107039     | waiting_for_applicant |
      | bob@barkybobs.com | 6222279082     | under_review          |
      | nils@random.com   | 6613265393     | under_review          |
      | hans@random.com   | 6914762726     | under_review          |
      | nils@random.com   | 7661057765     | under_review          |
      | bob@barkybobs.com | 7736362901     | under_review          |
      | emma@random.com   | 8025085252     | waiting_for_applicant |
      | emma@random.com   | 8028973322     | waiting_for_applicant |
      | hans@random.com   | 8356502446     | under_review          |
      | nils@random.com   | 8394317054     | under_review          |
      | bob@barkybobs.com | 8423893877     | under_review          |
      | emma@random.com   | 8589182768     | waiting_for_applicant |
      | hans@random.com   | 8616006592     | under_review          |
      | bob@barkybobs.com | 8728875504     | under_review          |
      | nils@random.com   | 8764985894     | under_review          |
      | bob@barkybobs.com | 8822107739     | under_review          |
      | hans@random.com   | 8909248752     | under_review          |
      | nils@random.com   | 9074668568     | under_review          |
      | bob@barkybobs.com | 9243957975     | under_review          |
      | emma@random.com   | 9267816362     | waiting_for_applicant |
      | hans@random.com   | 9360289459     | under_review          |
      | nils@random.com   | 9475077674     | under_review          |



  @selenium
  Scenario: Pagination: default is All, can set to just 10 items
    Given I am logged in as "admin@shf.se"
    And I am on the "membership applications" page
    And I hide the search form
    Then "items_count" should have "All" selected
    And I select "10" in select list "items_count"
    Then "items_count" should have "10" selected
    # prevents getting the element not clickable at that position error in Chrome
    And I scroll to the top
    When I click on t("shf_applications.index.org_nr")
    And I should see "6914762726"
    And I should not see "7661057765"
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
