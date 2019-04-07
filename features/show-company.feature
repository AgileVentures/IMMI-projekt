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
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name      |
      | Alingsås  |
      | Bromölla  |

    Given the following companies exist:
      | name     | company_number | email          | region       | kommun   | visibility     |
      | Company1 | 5560360793     | cmpy1@mail.com | Stockholm    | Alingsås | street_address |
      | Company2 | 2120000142     | cmpy2@mail.com | Västerbotten | Bromölla | street_address |
      | Company3 | 6613265393     | cmpy3@mail.com | Stockholm    | Alingsås | post_code      |
      | Company4 | 6222279082     | cmpy4@mail.com | Stockholm    | Alingsås | city           |
      | Company5 | 8025085252     | cmpy5@mail.com | Stockholm    | Alingsås | kommun         |
      | Company6 | 6914762726     | cmpy6@mail.com | Stockholm    | Alingsås | none           |
      | Company7 | 7661057765     | cmpy7@mail.com | Stockholm    | Alingsås | street_address |
      | Company8 | 7736362901     | cmpy8@mail.com | Stockholm    | Alingsås | street_address |

    And the following users exists
      | email           | admin | member |
      | user1@mutts.com |       | true   |
      | user2@mutts.com |       | true   |
      | user3@mutts.com |       | true   |
      | user4@mutts.com |       | true   |
      | user5@mutts.com |       | true   |
      | admin@shf.se    | true  | false  |

    Given the following payments exist
      | user_email      | start_date | expire_date | payment_type | status | hips_id |
      | user2@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | user3@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |


    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Rehab        |
      | Walker       |
      | JustForFun   |

    And the following applications exist:
      | user_email      | company_number | categories              | state    |
      | user1@mutts.com | 5560360793     | Groomer, JustForFun     | accepted |
      | user2@mutts.com | 2120000142     | Groomer, Trainer, Rehab | accepted |
      | user3@mutts.com | 6914762726     | Psychologist, Groomer   | accepted |
      | user4@mutts.com | 6613265393     | Groomer                 | accepted |
      | user5@mutts.com | 2120000142     | Psychologist            | accepted |

    And the following payments exist
      | user_email   | start_date | expire_date | payment_type | status | hips_id | company_number |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6613265393     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6222279082     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8025085252     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7661057765     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7736362901     |


  Scenario: Show company details to a visitor, but don't show the org nr.
    Given I am Logged out
    And I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should see "Company1"
    And I should see "Groomer"
    And I should see t("companies.show.members")
    And I should see "Firstname Lastname"
    And I should see "cmpy1@mail.com"
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
    And I should see "cmpy2@mail.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"

  Scenario: Show company details to member of the company.
    Given I am logged in as "user1@mutts.com"
    And I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should see "Company1"
    And I should see "Groomer"
    And I should see "JustForFun"
    And I should see "cmpy1@mail.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"

  Scenario: Show company details to admin and do show the org nr.
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "5560360793"
    Then I should see "5560360793"
    And I should see "Company1"
    And I should see "Groomer"
    And I should see "JustForFun"
    And I should see "cmpy1@mail.com"
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
    And I should see "cmpy2@mail.com"
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
    Given I am logged in as "user3@mutts.com"
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
    And I should see "Company6"
    And I should not see "Hundforetagarevägen 1"
    And I should not see "310 40"
    And I should not see "Harplinge"
    And I should not see "Alingsås"
