Feature: Show company page - display different info depending on role

  As a visitor,
  So that I can see if a company can provide the services I need,
  Show me the details about a company
  And show the address details consistent with the visibility setting

  Because some Org Nr.s are actually for individuals and we don't have a reliable
  way to tell if they are or not, and because we do not want to
  (and legally cannot) show the org nr. for an individual,
  only show the Org Nr to admins.

  PivotalTracker: https://www.pivotaltracker.com/story/show/135474603


  Background:

    Given the date is set to "2019-06-06"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |

    Given the following companies exist:
      | name                                  | company_number | email                      | region       | kommun   | city      | visibility     |
      | Co.1 - Addr Visible to Street Address | 5560360793     | hello@company-1.com        | Stockholm    | Alingsås | Harplinge | street_address |
      | Company2                              | 2120000142     | hello@company-2.com        | Västerbotten | Bromölla | Harplinge | street_address |
      | Company3                              | 6613265393     | hello@company-3.com        | Stockholm    | Alingsås | Harplinge | post_code      |
      | Company4                              | 6222279082     | hello@company-4.com        | Stockholm    | Alingsås | Harplinge | city           |
      | Company5                              | 8025085252     | hello@company-5.com        | Stockholm    | Alingsås | Harplinge | kommun         |
      | Co.6 - Address Not Visible            | 6914762726     | hello@addr-not-visible.com | Stockholm    | Alingsås | Harplinge | none           |
      | Company7                              | 7661057765     | hello@company-7.com        | Stockholm    | Alingsås | Harplinge | street_address |
      | Company8                              | 7736362901     | hello@company-8.com        | Stockholm    | Alingsås | Harplinge | street_address |

    And the following users exist:
      | email                            | admin | membership_status | member |
      | member-1@addr-all-visible-1.com  |       | current_member    | true   |
      | member@company-2.com             |       | current_member    | true   |
      | applicant-6@addr-not-visible.com |       |                   | false  |
      | member-6@addr-not-visible.com    |       | current_member    | true   |
      | member-no-payments@company-3.com |       | current_member    | true   |
      | member-no-payments@company-2.com |       | current_member    | true   |
      | member-2@addr-all-visible-1.com  |       | current_member    | true   |
      | admin@shf.se                     | true  |                   | false  |


    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Rehab        |
      | Walker       |
      | JustForFun   |

    And the following applications exist:
      | user_email                       | company_number | categories                        | state    |
      | member-1@addr-all-visible-1.com  | 5560360793     | Groomer, JustForFun               | accepted |
      | member@company-2.com             | 2120000142     | Groomer, Trainer, Rehab           | accepted |
      | applicant-6@addr-not-visible.com | 6914762726     | Groomer                           | new      |
      | member-6@addr-not-visible.com    | 6914762726     | Psychologist, Groomer             | accepted |
      | member-no-payments@company-3.com | 6613265393     | Groomer                           | accepted |
      | member-no-payments@company-2.com | 2120000142     | Psychologist                      | accepted |
      | member-2@addr-all-visible-1.com  | 5560360793     | Groomer, JustForFun, Psychologist | accepted |


    And the following payments exist
      | user_email                       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member-1@addr-all-visible-1.com  | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |                |
      | member@company-2.com             | 2019-10-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-6@addr-not-visible.com    | 2019-10-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-2@addr-all-visible-1.com  | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |                |
      | member-2@addr-all-visible-1.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | member@company-2.com             | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | member-no-payments@company-3.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6613265393     |
      | admin@shf.se                     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6222279082     |
      | admin@shf.se                     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8025085252     |
      | member-6@addr-not-visible.com    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |
      | admin@shf.se                     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7661057765     |
      | admin@shf.se                     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7736362901     |

    And the following memberships exist:
      | email                           | first_day  | last_day   |
      | member-1@addr-all-visible-1.com | 2019-01-01 | 2019-12-31 |
      | member@company-2.com            | 2019-10-1  | 2019-12-31 |
      | member-6@addr-not-visible.com   | 2019-10-1  | 2019-12-31 |
      | member-2@addr-all-visible-1.com | 2019-01-01 | 2019-12-31 |

   # --------------------------------------------------------------------------------------------

  Scenario: Show company details to a visitor, but don't show the org nr.
    Given I am Logged out
    When I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should see "Co.1 - Addr Visible to Street Address"
    And I should see "Groomer"
    And I should see t("companies.show.members")
    And I should see "Firstname Lastname"
    And I should see "hello@company-1.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"

    When I am the page for company number "2120000142"
    Then I should not see "2120000142"
    And I should see "Company2"
    And I should see "Groomer"
    And I should see "Trainer"
    And I should see "Rehab"
    And I should see "Psychologist"
    And I should see "hello@company-2.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"


  Scenario: Show company details to member of the company
    Given I am logged in as "member-1@addr-all-visible-1.com"
    When I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should see "Co.1 - Addr Visible to Street Address"
    And I should see "Groomer"
    And I should see "JustForFun"
    And I should see "hello@company-1.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"


  Scenario: Show company details to admin and do show the org nr.
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "5560360793"
    Then I should see "5560360793"
    And I should see "Co.1 - Addr Visible to Street Address"
    And I should see "Groomer"
    And I should see "JustForFun"
    And I should see "hello@company-1.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"

    When I am the page for company number "2120000142"
    Then I should see "2120000142"
    And I should see "Company2"
    And I should see "Groomer"
    And I should see "Trainer"
    And I should see "Rehab"
    And I should see "Psychologist"
    And I should see "hello@company-2.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"


  Scenario: Show company address to admin regardless of visibility setting
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "6914762726"
    Then I should see "6914762726"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "Alingsås"


  @time_adjust
  Scenario: Show company address to member regardless of visibility setting
    Given the date is set to "2017-10-01"
    Given I am logged in as "member-6@addr-not-visible.com"
    And I am the page for company number "6914762726"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "Alingsås"

  Scenario: Visitor: Don't show company street address
    Given I am Logged out
    And I am the page for company number "6613265393"
    And I should see "Company3"
    And I should not see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "Alingsås"

  Scenario: Visitor: Don't show company street address or postal code
    Given I am Logged out
    And I am the page for company number "6222279082"
    And I should see "Company4"
    And I should not see "Hundforetagarevägen 1"
    And I should not see "310 40"
    And I should see "Harplinge"
    And I should see "Alingsås"

  Scenario: Visitor: Don't show company street, postal code or city
    Given I am Logged out
    And I am the page for company number "8025085252"
    And I should see "Company5"
    And I should not see "Hundforetagarevägen 1"
    And I should not see "310 40"
    And I should not see "Harplinge"
    And I should see "Alingsås"

  Scenario: Visitor: Don't show company address
    Given I am Logged out
    And I am the page for company number "6914762726"
    And I should see "Co.6 - Address Not Visible"
    And I should not see "Hundforetagarevägen 1"
    And I should not see "310 40"
    And I should not see "Harplinge"
    And I should not see "Alingsås"


  Scenario: Should not show duplicate Business Categories
    Given I am logged out
    And I am the page for company number "5560360793"

    # Should see 'Groomer' once in the list of categories, once for user1 and once for user6 = 3 total
    And I should see 3 visible "Groomer"
    # Should see 'JustForFun' once in the list of categories, once for user1 and once for user6 = 3 total
    And I should see 3 visible "JustForFun"
    # Should see 'Psychologist' once in the list of categories, and once for user6 = 2 total
    And I should see 2 visible "Psychologist"
