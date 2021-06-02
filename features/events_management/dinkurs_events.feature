Feature: Get events for a company from Dinkurs

  As a member of a company
  I need to be able to have my Dinkurs events show on my company page
  Which can occur by my entering a dinkurs ID (that identifies my company at Dinkurs)
  Or by fetching Dinkurs events on-demand

  As a visitor
  I want to see schduled company events when I view the company's page

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email            | admin | membership_status |member |agreed_to_membership_guidelines |
      | member@mutts.com |       | current_member    |true   | true                           |
      | visitor@mail.com |       |                   |        |                                |
      | admin@shf.se     | true  |                   |      |                                |

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

    And the following memberships exist:
      | email | first_day | last_day |
      | member@mutts.com | 2017-01-01 | 2017-12-31 |

    # ---------------------------------------------------------------------------------------------

  @time_adjust @dinkurs_fetch
  Scenario: Member adds Dinkurs ID, checks as visible and visitor sees events in company page
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the "my first company" page for "member@mutts.com"
    And I should not see t("events.show.name")
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "fake-dinkurs-company-id"
    And I check the checkbox with id "company_show_dinkurs_events"
    And I click on t("submit")
    And I should not see t("events.show.no_events")
    And I should not see t("events.show_not")
    And I should see "3" events
    Then I am logged out
    And I am logged in as "visitor@mail.com"
    And I am on the "landing" page
    And I click on "Mutts"
    And I should see t("events.show.name")
    And I should not see t("events.show.no_events")
    And I should see "3" events

  @time_adjust @dinkurs_fetch
  Scenario: Member adds Dinkurs ID and visitor does not see events in company page
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the "my first company" page for "member@mutts.com"
    And I should not see t("events.show.name")
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "fake-dinkurs-company-id"
    And I click on t("submit")
    And I should not see t("events.show.no_events")
    Then I am logged out
    And I am logged in as "visitor@mail.com"
    And I am on the "landing" page
    And I click on "Mutts"
    And I should not see t("events.show.name")
    And I should not see t("events.show.no_events")
    And I should not see t("events.show_not")

  @time_adjust @dinkurs_fetch
  Scenario: Member adds Dinkurs ID then member himself and admin, too, sees information about Showing Dinkurs Events being disabled
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the "my first company" page for "member@mutts.com"
    And I should not see t("events.show.name")
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "fake-dinkurs-company-id"
    And I click on t("submit")
    And I should not see t("events.show.no_events")
    And I should see t("events.show_not")
    Then I am logged out
    And I am logged in as "admin@shf.se"
    And I am on the "all companies" page
    And I click on "Mutts"
    And I should not see t("events.show.no_events")
    And I should see t("events.show_not")

  @time_adjust @dinkurs_invalid_key
  Scenario: Member edits company, enters invalid Dinkurs ID, sees validation error
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "wrongkey"
    And I click on t("submit")
    Then I should see t("activerecord.errors.models.company.attributes.dinkurs_company_id.invalid_key")

  @time_adjust @dinkurs_invalid_key
  Scenario: Member edits company, enters Dinkurs ID with invalid chars, sees validation error
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "Åö"
    And I click on t("submit")
    Then I should see t("activerecord.errors.models.company.attributes.dinkurs_company_id.invalid_chars")


  @time_adjust @selenium @dinkurs_fetch
  Scenario: Member fetches Dinkurs events
    Given the date is set to "2017-10-01"
    And I am logged in as "member@mutts.com"
    And I am on the "my first company" page for "member@mutts.com"
    And I should not see t("events.show.name")
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.show.dinkurs_key") with "fake-dinkurs-company-id"
    And I check the bootstrap checkbox with id "company_show_dinkurs_events"
    And I click on t("submit")
    And I should not see t("events.show.no_events")
    And I should see "3" events
    Then all events for the company named "Mutts" are deleted from the database
    And I reload the page
    And I should see t("events.show.no_events")
    Then I click on t("companies.show.dinkurs_fetch_events") button
    And I wait for all ajax requests to complete
    Then I should see "3" events
