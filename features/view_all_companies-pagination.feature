Feature: Visitor sets number of companies to show (pagination for 'all companies' view)

  As a visitor,
  so that I can view the list of companies in a way that suits me and my device,
  I want to be able to control how many companies are shown on a page. (pagination)


  Note that the interaction with the 'show/hide search form' UI item and the
  pagination select list ('items_count') both are XHR requests.  You must be sure
  to wait until they are complete.  Capybara may proceed before things are
  actually returned and updated, which leads to unpredictable results.



  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |

    And the following users exists
      | email              | admin | member |
      | accepted@mutts.com |       | true   |
      | admin@shf.se       | true  |        |


    Given the following companies exist:
      | name      | company_number | email                  | region       | kommun   |
      | Company01 | 5560360793     | snarky@snarkybarky.com | Stockholm    | Alingsås |
      | Company02 | 2120000142     | bowwow@bowsersy.com    | Västerbotten | Bromölla |
      | Company03 | 6613265393     | cmpy3@mail.com         | Stockholm    | Alingsås |
      | Company04 | 6222279082     | cmpy4@mail.com         | Stockholm    | Alingsås |
      | Company05 | 8025085252     | cmpy5@mail.com         | Stockholm    | Alingsås |
      | Company06 | 6914762726     | cmpy6@mail.com         | Stockholm    | Alingsås |
      | Company07 | 7661057765     | cmpy7@mail.com         | Stockholm    | Alingsås |
      | Company08 | 7736362901     | cmpy8@mail.com         | Stockholm    | Alingsås |
      | Company09 | 6112107039     | cmpy9@mail.com         | Stockholm    | Alingsås |
      | Company10 | 3609340140     | cmpy10@mail.com        | Stockholm    | Alingsås |
      | Company11 | 2965790286     | cmpy11@mail.com        | Stockholm    | Alingsås |
      | Company12 | 4268582063     | cmpy12@mail.com        | Stockholm    | Alingsås |
      | Company13 | 8028973322     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company14 | 8356502446     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company15 | 8394317054     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company16 | 8423893877     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company17 | 8589182768     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company18 | 8616006592     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company19 | 8764985894     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company20 | 8822107739     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company21 | 8853655168     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company22 | 8909248752     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company23 | 9074668568     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company24 | 9243957975     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company25 | 9267816362     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company26 | 9360289459     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company27 | 9475077674     | cmpy13@mail.com        | Stockholm    | Alingsås |


    And the following applications exist:
      | user_email         | company_number | state    |
      | accepted@mutts.com | 5560360793     | accepted |
      | accepted@mutts.com | 2120000142     | accepted |
      | accepted@mutts.com | 6613265393     | accepted |
      | accepted@mutts.com | 6222279082     | accepted |
      | accepted@mutts.com | 8025085252     | accepted |
      | accepted@mutts.com | 6914762726     | accepted |
      | accepted@mutts.com | 7661057765     | accepted |
      | accepted@mutts.com | 7736362901     | accepted |
      | accepted@mutts.com | 6112107039     | accepted |
      | accepted@mutts.com | 3609340140     | accepted |
      | accepted@mutts.com | 2965790286     | accepted |
      | accepted@mutts.com | 4268582063     | accepted |
      | accepted@mutts.com | 8028973322     | accepted |
      | accepted@mutts.com | 8356502446     | accepted |
      | accepted@mutts.com | 8394317054     | accepted |
      | accepted@mutts.com | 8423893877     | accepted |
      | accepted@mutts.com | 8589182768     | accepted |
      | accepted@mutts.com | 8616006592     | accepted |
      | accepted@mutts.com | 8764985894     | accepted |
      | accepted@mutts.com | 8822107739     | accepted |
      | accepted@mutts.com | 8853655168     | accepted |
      | accepted@mutts.com | 8909248752     | accepted |
      | accepted@mutts.com | 9074668568     | accepted |
      | accepted@mutts.com | 9243957975     | accepted |
      | accepted@mutts.com | 9267816362     | accepted |
      | accepted@mutts.com | 9360289459     | accepted |
      | accepted@mutts.com | 9475077674     | accepted |


    And the following payments exist
      | user_email         | start_date | expire_date | payment_type | status | hips_id | company_number |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6613265393     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6222279082     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8025085252     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7661057765     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7736362901     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6112107039     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 3609340140     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2965790286     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 4268582063     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8028973322     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8356502446     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8394317054     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8423893877     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8589182768     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8616006592     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8764985894     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8822107739     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8853655168     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8909248752     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9074668568     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9243957975     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9267816362     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9360289459     |
      | accepted@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9475077674     |


  @selenium @time_adjust
  Scenario: default number shown is 10
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("activerecord.attributes.company.name") link
    And I click on t("toggle.company_search_form.hide")
    And I should see "Company02"
    And I should not see "2120000142"
    And I should see "Company01"
    And I should not see "5560360793"
    And I should see "Company10"
    And I should not see "3609340140"
    And I should not see "Company11"
    Then I click on t("will_paginate.next_label") link
    And I should see "Company11"
    And I should not see "Company10"
    And I should not see "Company27"


  @selenium @time_adjust
  Scenario: view 10 companies; ensure the company name is not shown if it is > items_count selected to show
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I click on t("activerecord.attributes.company.name") link
    And I wait for all ajax requests to complete
    And "items_count" should have "10" selected
    And I should see "Company01"
    And I should see "Company02"
    And I should not see "Company26"
    And I should not see "Company27"


  @selenium @time_adjust
  Scenario: view 25 companies; ensure the company name is not shown if it is > items_count selected to show
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I click on t("activerecord.attributes.company.name") link
    And I wait for all ajax requests to complete
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    And "items_count" should have "25" selected
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company24"
    And I should see "Company25"
    And I should not see "Company26"
    And I should not see "Company27"


  @selenium @time_adjust
  Scenario: view all companies
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I click on t("activerecord.attributes.company.name") link
    And I wait for all ajax requests to complete
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "27" companies
    And "items_count" should have "All" selected
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company26"
    And I should see "Company27"


  @selenium @time_adjust
  Scenario: Pagination: Change number of items multiple times
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I click on t("activerecord.attributes.company.name") link
    And I wait for all ajax requests to complete
    And "items_count" should have "10" selected
    And I should see "10" companies
    And I should see "Company10"
    And I should not see "Company11"
    And I should not see "Company26"
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    And "items_count" should have "25" selected
    Then I should see "25" companies
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company24"
    And I should see "Company25"
    And I should not see "9360289459"
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "27" companies
    And I should see "Company26"
    And I should see "Company27"
