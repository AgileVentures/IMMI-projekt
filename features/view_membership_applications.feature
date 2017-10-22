Feature: As an admin,
  so that I can manage membership applications,
  I want to see all membership applications

  Background:
    Given the following users exists
      | email             | is_member | admin |
      | emma@random.com   | false     | true  |
      | hans@random.com   | false     | true  |
      | nils@random.com   | true      | true  |
      | bob@barkybobs.com | true      | true  |
      | admin@shf.se      | true      | true  |

    And the following simple applications exist:
      | user_email        | company_number | state                 |
      | emma@random.com   | 0000000001     | waiting_for_applicant |
      | hans@random.com   | 0000000002     | under_review          |
      | nils@random.com   | 0000000003     | under_review          |
      | bob@barkybobs.com | 0000000004     | under_review          |
      | emma@random.com   | 0000000005     | waiting_for_applicant |
      | hans@random.com   | 0000000006     | under_review          |
      | nils@random.com   | 0000000007     | under_review          |
      | bob@barkybobs.com | 0000000008     | under_review          |
      | emma@random.com   | 0000000009     | waiting_for_applicant |
      | hans@random.com   | 0000000010     | under_review          |
      | nils@random.com   | 0000000011     | under_review          |
      | bob@barkybobs.com | 0000000012     | under_review          |
      | emma@random.com   | 0000000013     | waiting_for_applicant |
      | hans@random.com   | 0000000014     | under_review          |
      | nils@random.com   | 0000000015     | under_review          |
      | bob@barkybobs.com | 0000000016     | under_review          |
      | emma@random.com   | 0000000017     | waiting_for_applicant |
      | hans@random.com   | 0000000018     | under_review          |
      | nils@random.com   | 0000000019     | under_review          |
      | bob@barkybobs.com | 0000000020     | under_review          |
      | emma@random.com   | 0000000021     | waiting_for_applicant |
      | hans@random.com   | 0000000022     | under_review          |
      | nils@random.com   | 0000000023     | under_review          |
      | bob@barkybobs.com | 0000000024     | under_review          |
      | emma@random.com   | 0000000025     | waiting_for_applicant |
      | hans@random.com   | 0000000026     | under_review          |
      | nils@random.com   | 0000000027     | under_review          |
      | bob@barkybobs.com | 0000000028     | under_review          |

    And I am logged in as "admin@shf.se"
    And I am on the "membership applications" page
    And I click on t("toggle.company_search_form.hide")

  @selenium
  Scenario: Pagination
    And I select "10" in select list "items_count"
    And I should see "0000000010"
    And I should not see "0000000011"
    Then I click on t("will_paginate.next_label") link
    And I should see "0000000011"
    And I should not see "0000000010"
    And I should not see "0000000021"
    Then I click on t("will_paginate.next_label") link
    And I should see "0000000021"
    And I should not see "0000000020"

  @selenium
  Scenario: Pagination: Set number of items per page
    Then "items_count" should have "All" selected
    And I should see "28" applications
    And I should see "0000000026"
    And I should see "0000000028"
    Then I select "25" in select list "items_count"
    And I should see "25" applications
    And "items_count" should have "25" selected
    And I should see "0000000010"
    And I should see "0000000025"
    And I should not see "0000000026"
    Then I select "10" in select list "items_count"
    And I should see "10" applications
    And I should see "0000000010"
    And I should not see "0000000025"
