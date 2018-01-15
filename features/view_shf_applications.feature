Feature: As an admin,
  so that I can manage membership applications,
  I want to see all membership applications

  Background:

    Given the following users exists
      | email             | admin | member |
      | emma@random.com   |       | false  |
      | hans@random.com   |       | false  |
      | nils@random.com   |       | true   |
      | bob@barkybobs.com |       | true   |
      | admin@shf.se      | true  | false  |


    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Walker       |


    And the following applications exist:
      | user_email        | company_number | state                 |
      | emma@random.com   | 5560360793     | waiting_for_applicant |
      | hans@random.com   | 2120000142     | under_review          |
      | nils@random.com   | 6613265393     | under_review          |
      | bob@barkybobs.com | 6222279082     | under_review          |
      | emma@random.com   | 8025085252     | waiting_for_applicant |
      | hans@random.com   | 6914762726     | under_review          |
      | nils@random.com   | 7661057765     | under_review          |
      | bob@barkybobs.com | 7736362901     | under_review          |
      | emma@random.com   | 6112107039     | waiting_for_applicant |
      | hans@random.com   | 3609340140     | under_review          |
      | nils@random.com   | 2965790286     | under_review          |
      | bob@barkybobs.com | 4268582063     | under_review          |
      | emma@random.com   | 8028973322     | waiting_for_applicant |
      | hans@random.com   | 8356502446     | under_review          |
      | nils@random.com   | 8394317054     | under_review          |
      | bob@barkybobs.com | 8423893877     | under_review          |
      | emma@random.com   | 8589182768     | waiting_for_applicant |
      | hans@random.com   | 8616006592     | under_review          |
      | nils@random.com   | 8764985894     | under_review          |
      | bob@barkybobs.com | 8822107739     | under_review          |
      | emma@random.com   | 2965790286     | waiting_for_applicant |
      | hans@random.com   | 8909248752     | under_review          |
      | nils@random.com   | 9074668568     | under_review          |
      | bob@barkybobs.com | 9243957975     | under_review          |
      | emma@random.com   | 9267816362     | waiting_for_applicant |
      | hans@random.com   | 9360289459     | under_review          |
      | nils@random.com   | 9475077674     | under_review          |
      | bob@barkybobs.com | 8728875504     | under_review          |

    And I am logged in as "admin@shf.se"
    And I am on the "membership applications" page


  @selenium
  Scenario: The page has all the information and elements expected; search is shown by default
    And I should see button t("admin.index.export")
    And I should see button t("toggle.application_search_form.hide")
    And I should see t("shf_applications.index.membership_number")
    And I should see t("shf_applications.index.name")
    And I should see t("shf_applications.index.org_nr")
    And I should see t("shf_applications.index.state")


  @selenium
  Scenario: Pagination
    And I should see t("toggle.application_search_form.hide")
    # Hide the search elements
    And I click on t("toggle.application_search_form.hide")
    And I wait for all ajax requests to complete
    And I should see t("toggle.application_search_form.show")
    Then I should not see t("toggle.application_search_form.hide")

    # ensure they are sorted
    And I click on t("shf_applications.index.org_nr") link
    And I wait for all ajax requests to complete
    And I select "10" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "2120000142" before "2965790286"
    And I should see "2965790286" before "3609340140"
    And I should see "3609340140" before "4268582063"
    And I should see "4268582063" before "5560360793"
    And I should see "5560360793" before "6112107039"
    And I should see "6112107039" before "6222279082"
    And I should see "6222279082" before "6613265393"
    And I should see "6613265393" before "6914762726"
    And I should see "6914762726" before "7661057765"
    And I should see "7661057765" before "7736362901"
    And I should see "7736362901" before "8025085252"
    And I should see "8025085252" before "8356502446"

    And I should see "2120000142"
    And I should see "8356502446"
    And I should not see "8394317054"
    Then I click on t("will_paginate.next_label") link
    And I wait for all ajax requests to complete
    And I should see "8394317054"
    And I should not see "2120000142"
    And I should not see "8356502446"
    And I should not see "8356502446"
    Then I click on t("will_paginate.next_label") link
    And I wait for all ajax requests to complete
    And I should see "2965790286"
    And I should not see "9475077674"


  @selenium
  Scenario: Pagination default value is All


  @selenium
  Scenario: Pagination: Set number of items per page
    Then "items_count" should have "All" selected
    And I should see "28" applications
    And I should see "9360289459"
    And I should see "8728875504"
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    And I should see "25" applications
    And "items_count" should have "25" selected
    And I click on t("shf_applications.index.org_nr") link
    And I wait for all ajax requests to complete
    And I should see "3609340140"
    And I should see "9267816362"
    And I should not see "9360289459"
    Then I select "10" in select list "items_count"
    And I wait for all ajax requests to complete
    And I should see "10" applications
    And I should see "3609340140"
    And I should not see "9267816362"
