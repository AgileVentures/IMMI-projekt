Feature: As a member of a company
  I need to be able to have my Dinkurs events show on my company page
  Which can occur by my entering a dinkurs ID (that identifies my company at Dinkurs)
  Or by fetching Dinkurs events on-demand

  As a visitor
  I want to see schduled company events when I view the company's page

  Background:
    Given the following users exists
      | email            | admin | member |
      | member@mutts.com |       | true   |
      | visitor@mail.com |       |        |

    And the following regions exist:
      | name         |
      | Stockholm    |

    And the following kommuns exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name  | company_number | email          | region     | kommun    |
      | Mutts | 5560360793     | info@mutts.com | Stockholm  | Stockholm |

    And the following payments exist
      | user_email       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |

    And the following applications exist:
      | user_email       | company_number | state    |
      | member@mutts.com | 5560360793     | accepted |

  @time_adjust
  Scenario: Member adds Dinkurs ID and visitor sees events in company page
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the "my first company" page for "member@mutts.com"
    And I should not see t("events.show.name")
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "ENV['DINKURS_COMPANY_TEST_ID']"
    And I click on t("submit")
    And I should not see t("events.show.no_events")
    And I should see "4" events
    Then I am logged out
    And I am logged in as "visitor@mail.com"
    And I am on the "landing" page
    And I click on "Mutts"
    And I should see t("events.show.name")
    And I should not see t("events.show.no_events")
    And I should see "4" events

  @time_adjust
  Scenario: Member edits company, enters invalid Dinkurs ID, sees validation error
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "wrongkey"
    And I click on t("submit")
    Then I should see t("activerecord.errors.models.company.attributes.dinkurs_company_id.invalid")

  @time_adjust @selenium
  Scenario: Member fetches Dinkurs events
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the "my first company" page for "member@mutts.com"
    And I should not see t("events.show.name")
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "ENV['DINKURS_COMPANY_TEST_ID']"
    And I click on t("submit")
    And I should see "4" events
    Then all events for the company named "Mutts" are deleted from the database
    And I reload the page
    And I should see t("events.show.no_events")
    Then I click on t("companies.show.dinkurs_fetch_events") button
    And I wait for all ajax requests to complete
    Then I should see "4" events
