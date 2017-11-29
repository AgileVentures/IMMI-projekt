Feature: As a visitor,
  so that I can find companies that can offer me services,
  I want to see all companies

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
      | name      | company_number | email                  | region       | kommun  |
      | Company1  | 5560360793     | snarky@snarkybarky.com | Stockholm    | Alingsås|
      | Company2  | 2120000142     | bowwow@bowsersy.com    | Västerbotten | Bromölla|
      | Company3  | 6613265393     | cmpy3@mail.com         | Stockholm    | Alingsås|
      | Company4  | 6222279082     | cmpy4@mail.com         | Stockholm    | Alingsås|
      | Company5  | 8025085252     | cmpy5@mail.com         | Stockholm    | Alingsås|
      | Company6  | 6914762726     | cmpy6@mail.com         | Stockholm    | Alingsås|
      | Company7  | 7661057765     | cmpy7@mail.com         | Stockholm    | Alingsås|
      | Company8  | 7736362901     | cmpy8@mail.com         | Stockholm    | Alingsås|
      | Company9  | 6112107039     | cmpy9@mail.com         | Stockholm    | Alingsås|
      | Company10 | 3609340140     | cmpy10@mail.com        | Stockholm    | Alingsås|
      | Company11 | 2965790286     | cmpy11@mail.com        | Stockholm    | Alingsås|
      | Company12 | 4268582063     | cmpy12@mail.com        | Stockholm    | Alingsås|
      | Company13 | 8028973322     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company14 | 8356502446     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company15 | 8394317054     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company16 | 8423893877     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company17 | 8589182768     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company18 | 8616006592     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company19 | 8764985894     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company20 | 8822107739     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company21 | 8853655168     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company22 | 8909248752     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company23 | 9074668568     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company24 | 9243957975     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company25 | 9267816362     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company26 | 9360289459     | cmpy13@mail.com        | Stockholm    | Alingsås|
      | Company27 | 9475077674     | cmpy13@mail.com        | Stockholm    | Alingsås|

    And the following users exists
      | email        | admin |
      | a@mutts.com  |       |
      | admin@shf.se | true  |

    And the following payments exist
      | user_email  | start_date | expire_date | payment_type | status | hips_id | company_number |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6613265393     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6222279082     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8025085252     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7661057765     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7736362901     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6112107039     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 3609340140     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2965790286     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 4268582063     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8028973322     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8356502446     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8394317054     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8423893877     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8589182768     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8616006592     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8764985894     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8822107739     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8853655168     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8909248752     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9074668568     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9243957975     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9267816362     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9360289459     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9475077674     |

  @selenium @time_adjust
  Scenario: Visitor sees all companies
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I should see "Company2"
    And I should not see "2120000142"
    And I should see "Company1"
    And I should not see "5560360793"
    And I should not see t("companies.new_company")

  @time_adjust
  Scenario: User sees all the companies
    Given the date is set to "2017-10-01"
    Given I am logged in as "a@mutts.com"
    And I am on the "landing" page
    Then I should see t("companies.index.title")
    And I should see "Company2"
    And I should not see "2120000142"
    And I should see "Company1"
    And I should not see "5560360793"
    And I should not see t("companies.new_company")

  @selenium @time_adjust
  Scenario: Pagination
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I should see "Company2"
    And I should not see "2120000142"
    And I should see "Company1"
    And I should not see "5560360793"
    And I should see "Company10"
    And I should not see "3609340140"
    And I should not see "Company11"
    Then I click on t("will_paginate.next_label") link
    And I should see "Company11"
    And I should not see "Company10"

  @selenium @time_adjust
  Scenario: I18n translations
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I set the locale to "sv"
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    Then I click on t("toggle.company_search_form.hide") button
    And I should see "Verksamhetslän"
    And I should see "Kategori"
    And I should not see "Region"
    And I should not see "Category"
    Then I click on "change-lang-to-english"
    And I set the locale to "en"
    Then I click on t("toggle.company_search_form.hide") button
    And I wait 1 second
    And I should see "Region"
    And I should see "Category"
    And I should not see "Verksamhetslän"
    And I should not see "Kategori"

  @selenium @time_adjust
  Scenario: Pagination: Set number of items per page
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And "items_count" should have "10" selected
    And I should see "10" companies
    And I should see "Company10"
    And I should not see "Company11"
    And I should not see "Company26"
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "25" companies
    And "items_count" should have "25" selected
    And I should see "Company10"
    And I should see "Company11"
    And I should see "Company25"
    And I should not see "Company26"
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "27" companies
    And I should see "Company26"
    And I should see "Company27"
