Feature: Visitor sees all companies

  As a visitor,
  so that I can find companies that can offer me services,
  I want to see all companies

  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |
      | Uppsala      |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |
      | Alvesta  |
      | Aneby    |

    And the following business categories exist
      | name    |
      | Groomer |

    Given the following companies exist:
      | name      | company_number | email           | region       | kommun   |
      | Company01 | 5560360793     | cmpy1@mail.com  | Stockholm    | Alingsås |
      | Company02 | 2120000142     | cmpy2@mail.com  | Västerbotten | Bromölla |
      | Company03 | 6613265393     | cmpy3@mail.com  | Stockholm    | Alingsås |
      | Company04 | 6222279082     | cmpy4@mail.com  | Stockholm    | Alingsås |
      | Company05 | 8025085252     | cmpy5@mail.com  | Stockholm    | Alingsås |
      | Company06 | 6914762726     | cmpy6@mail.com  | Stockholm    | Alingsås |
      | Company07 | 7661057765     | cmpy7@mail.com  | Stockholm    | Alingsås |
      | Company08 | 7736362901     | cmpy8@mail.com  | Stockholm    | Alingsås |
      | Company09 | 6112107039     | cmpy9@mail.com  | Stockholm    | Alingsås |
      | Company10 | 3609340140     | cmpy10@mail.com | Stockholm    | Alingsås |
      | Company11 | 2965790286     | cmpy11@mail.com | Stockholm    | Alingsås |
      | Company12 | 4268582063     | cmpy12@mail.com | Stockholm    | Alingsås |
      | Company13 | 8028973322     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company14 | 8356502446     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company15 | 8394317054     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company16 | 8423893877     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company17 | 8589182768     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company18 | 8616006592     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company19 | 8764985894     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company20 | 8822107739     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company21 | 5569767808     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company22 | 8909248752     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company23 | 9074668568     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company24 | 9243957975     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company25 | 9267816362     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company26 | 9360289459     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company27 | 9475077674     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company28 | 8728875504     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company29 | 5872150379     | cmpy13@mail.com | Stockholm    | Alingsås |

    And the following company addresses exist:
      | company_name | region     | kommun  |
      | Company02    | Norrbotten | Alvesta |
      | Company02    | Uppsala    | Aneby   |

    And the following users exists
      | email         | admin | member |
      | u1@mutts.com  |       | true   |
      | u2@mutts.com  |       | true   |
      | u3@mutts.com  |       | true   |
      | u4@mutts.com  |       | true   |
      | u5@mutts.com  |       | true   |
      | u6@mutts.com  |       | true   |
      | u7@mutts.com  |       | true   |
      | u8@mutts.com  |       | true   |
      | u9@mutts.com  |       | true   |
      | u10@mutts.com |       | true   |
      | u11@mutts.com |       | true   |
      | u12@mutts.com |       | true   |
      | u13@mutts.com |       | true   |
      | u14@mutts.com |       | true   |
      | u15@mutts.com |       | true   |
      | u16@mutts.com |       | true   |
      | u17@mutts.com |       | true   |
      | u18@mutts.com |       | true   |
      | u19@mutts.com |       | true   |
      | u20@mutts.com |       | true   |
      | u21@mutts.com |       | true   |
      | u22@mutts.com |       | true   |
      | u23@mutts.com |       | true   |
      | u24@mutts.com |       | true   |
      | u25@mutts.com |       | true   |
      | u26@mutts.com |       | true   |
      | u27@mutts.com |       | true   |
      | u29@mutts.com |       | true   |
      | b@mutts.com   |       | false  |
      | admin@shf.se  | true  |        |

    And the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id | company_name |
      | u1@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company01    |
      | u1@mutts.com  | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |              |
      | u2@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company02    |
      | u3@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company03    |
      | u4@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company04    |
      | u5@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company05    |
      | u6@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company06    |
      | u7@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company07    |
      | u8@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company08    |
      | u9@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company09    |
      | u10@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company10    |
      | u11@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company11    |
      | u12@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company12    |
      | u13@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company13    |
      | u14@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company14    |
      | u15@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company15    |
      | u16@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company16    |
      | u17@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company17    |
      | u18@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company18    |
      | u19@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company19    |
      | u20@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company20    |
      | u21@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company21    |
      | u22@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company22    |
      | u23@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company23    |
      | u24@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company24    |
      | u25@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company25    |
      | u26@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company26    |
      | u27@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company27    |
      | u29@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company28    |

    And the following applications exist:
      | user_email    | company_name | state    | categories |
      | u1@mutts.com  | Company01    | accepted | Groomer    |
      | u2@mutts.com  | Company02    | accepted | Groomer    |
      | u3@mutts.com  | Company03    | accepted | Groomer    |
      | u4@mutts.com  | Company04    | accepted | Groomer    |
      | u5@mutts.com  | Company05    | accepted | Groomer    |
      | u6@mutts.com  | Company06    | accepted | Groomer    |
      | u7@mutts.com  | Company07    | accepted | Groomer    |
      | u8@mutts.com  | Company08    | accepted | Groomer    |
      | u9@mutts.com  | Company09    | accepted | Groomer    |
      | u10@mutts.com | Company10    | accepted | Groomer    |
      | u11@mutts.com | Company11    | accepted | Groomer    |
      | u12@mutts.com | Company12    | accepted | Groomer    |
      | u13@mutts.com | Company13    | accepted | Groomer    |
      | u14@mutts.com | Company14    | accepted | Groomer    |
      | u15@mutts.com | Company15    | accepted | Groomer    |
      | u16@mutts.com | Company16    | accepted | Groomer    |
      | u17@mutts.com | Company17    | accepted | Groomer    |
      | u18@mutts.com | Company18    | accepted | Groomer    |
      | u19@mutts.com | Company19    | accepted | Groomer    |
      | u20@mutts.com | Company20    | accepted | Groomer    |
      | u21@mutts.com | Company21    | accepted | Groomer    |
      | u22@mutts.com | Company22    | accepted | Groomer    |
      | u23@mutts.com | Company23    | accepted | Groomer    |
      | u24@mutts.com | Company24    | accepted | Groomer    |
      | u25@mutts.com | Company25    | accepted | Groomer    |
      | u26@mutts.com | Company26    | accepted | Groomer    |
      | u27@mutts.com | Company27    | accepted | Groomer    |
      | b@mutts.com   | Company28    | accepted | Groomer    |
      | u29@mutts.com | Company29    | accepted | Groomer    |

  @selenium @time_adjust
  Scenario: Visitor sees all companies
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see "Company02"
    And I should not see "2120000142"
    And I should see "Company01"
    And I should not see "5560360793"
    And I should not see t("companies.new_company")

  @selenium @time_adjust
  Scenario: Visitor sees multiple regions and kommuns for a company in the companies list
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    # Ensure the list is sorted by name so we will see Company02
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company02"
    And I should see "Västerbotten" in the row for "Company02"
    And I should see "Norrbotten" in the row for "Company02"
    And I should see "Uppsala" in the row for "Company02"
    And I should see "Bromölla" in the row for "Company02"
    And I should see "Alvesta" in the row for "Company02"
    And I should see "Aneby" in the row for "Company02"
    And I should not see "Stockholm" in the row for "Company02"

  @time_adjust
  Scenario: User sees all the companies
    Given the date is set to "2017-10-01"
    Given I am logged in as "u1@mutts.com"
    And I am on the "landing" page
    Then I should see t("companies.index.title")
    And I should see "Company02"
    And I should not see "2120000142"
    And I should see "Company01"
    And I should not see "5560360793"
    And I should not see t("companies.new_company")

  @selenium @time_adjust
  Scenario: Pagination
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    And I click on t("accordion_label.company_search_form.hide")
    # Ensure the list is sorted by name so we will see Company02
    And I click on t("activerecord.attributes.company.name")
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

  @selenium @time_adjust
  Scenario: I18n translations
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I set the locale to "sv"
    And I am on the "landing" page
    Then I click on t("accordion_label.company_search_form.hide")
    And I should see "Verksamhetslän"
    And I should see "Kategori"
    And I should not see "Region"
    And I should not see "Category"
    Then I click on "change-lang-to-english"
    And I set the locale to "en"
    Then I click on t("accordion_label.company_search_form.hide")
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
    And I click on t("accordion_label.company_search_form.hide")
    And "items_count" should have "10" selected
    And I should see "10" companies
    # Ensure the list is sorted by name so we will see Company02
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company10"
    And I should not see "Company11"
    And I should not see "Company26"
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "25" companies
    And "items_count" should have "25" selected
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company11"
    And I should see "Company12"
    And I should see "Company24"
    And I should see "Company25"
    And I should not see "Company26"

  @selenium @time_adjust
  Scenario: Companies lacking branding payment or members not shown
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    And I click on t("accordion_label.company_search_form.hide")
    And "items_count" should have "10" selected
    Then I select "All" in select list "items_count"
    And I should see "27" companies
    And I should see "Company10"
    And I should see "Company27"
    And I should not see "Company28"
    And I should not see "Company29"

  @selenium @time_adjust
  Scenario: Admin can see all companies even if lacking branding payment or members
    Given the date is set to "2017-10-01"
    And I am logged in as "admin@shf.se"
    And I am on the "all companies" page
    And "items_count" should have "10" selected
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    And I should see "29" companies
    And I should see "Company10"
    And I should see "Company27"
    And I should see "Company28"
    And I should see "Company29"
