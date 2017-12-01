Feature: As an admin
  I want to be able to change certain attributes associated with companies' branding license
  So that I have flexibility in managing branding status

  Background:
    Given the following users exist
      | email          | admin | is_member | membership_number |
      | admin@shf.se   | true  | true      | 1                 |
      | emma@mutts.com |       | true      | 1001              |

    Given the following companies exist:
      | name       | company_number | email                 | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com   | Stockholm |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | branding_fee | betald | none    | 2120000142     |

  @selenium
  Scenario: Admin edits branding status
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "2120000142"
    And I should see t("Yes")
    And I should see "2017-12-31"
    Then I click on t("companies.show.edit_branding_status")
    And I should see t("companies.show.edit_branding_status")
    And I should see t("activerecord.attributes.payment.expire_date")
    And I should see t("activerecord.attributes.payment.notes")
    And I select "2018" in select list "payment[expire_date(1i)]"
    Then I select "juni" in select list "payment[expire_date(2i)]"
    And I select "1" in select list "payment[expire_date(3i)]"
    And I fill in t("activerecord.attributes.payment.notes") with "This is a note regarding this company."
    Then I click on t("companies.company.submit_button_label")
    And I wait for all ajax requests to complete
    And I reload the page
    # ^^ should not have to do this - check later after upgrades
    And I should see "2018-06-01"
    And I should see "This is a note regarding this company."
