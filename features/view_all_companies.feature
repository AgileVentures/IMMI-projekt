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
      | name                 | company_number | email                  | region       | kommun  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm    | Alingsås|
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    | Västerbotten | Bromölla|
      | Company3             | 6613265393     | cmpy3@mail.com         | Stockholm    | Alingsås|
      | Company4             | 6222279082     | cmpy4@mail.com         | Stockholm    | Alingsås|
      | Company5             | 8025085252     | cmpy5@mail.com         | Stockholm    | Alingsås|
      | Company6             | 6914762726     | cmpy6@mail.com         | Stockholm    | Alingsås|
      | Company7             | 7661057765     | cmpy7@mail.com         | Stockholm    | Alingsås|
      | Company8             | 7736362901     | cmpy8@mail.com         | Stockholm    | Alingsås|
      | Company9             | 6112107039     | cmpy9@mail.com         | Stockholm    | Alingsås|
      | Company10            | 3609340140     | cmpy10@mail.com        | Stockholm    | Alingsås|
      | Company11            | 2965790286     | cmpy11@mail.com        | Stockholm    | Alingsås|
      | Company12            | 4268582063     | cmpy12@mail.com        | Stockholm    | Alingsås|
      | Company13            | 8028973322     | cmpy13@mail.com        | Stockholm    | Alingsås|

    And the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | a@happymutts.com    |       |
      | admin@shf.se        | true  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Rehab        |
      | Walker       |
      | JustForFun   |

    And the following applications exist:
      | first_name | user_email          | company_number | category_name           | state    |
      | Emma       | emma@happymutts.com | 5560360793     | Groomer, JustForFun     | accepted |
      | Anna       | a@happymutts.com    | 2120000142     | Groomer, Trainer, Rehab | accepted |
      | Emma       | emma@happymutts.com | 2120000142     | Psychologist, Groomer   | accepted |
      | Anna       | a@happymutts.com    | 6613265393     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 6222279082     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 8025085252     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 6914762726     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 7661057765     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 7736362901     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 6112107039     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 3609340140     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 2965790286     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 4268582063     | Groomer                 | accepted |
      | Anna       | a@happymutts.com    | 8028973322     | Groomer                 | accepted |

  @javascript
  Scenario: Visitor sees all companies
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I should see "Bowsers"
    And I should not see "2120000142"
    And I should see "No More Snarky Barky"
    And I should not see "5560360793"
    And I should see "Groomer"
    And I should not see "Walker"
    And I should not see t("companies.new_company")


  Scenario: User sees all the companies
    Given I am logged in as "emma@happymutts.com"
    And I am on the "landing" page
    Then I should see t("companies.index.title")
    And I should see "Bowsers"
    And I should not see "2120000142"
    And I should see "No More Snarky Barky"
    And I should not see "5560360793"
    And I should not see t("companies.new_company")



  @javascript
  Scenario: Pagination
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I should see "Bowsers"
    And I should not see "2120000142"
    And I should see "No More Snarky Barky"
    And I should not see "5560360793"
    And I should see "Company10"
    And I should not see "3609340140"
    And I should not see "Company11"
    Then I click on t("will_paginate.next_label") link
    And I should see "Company11"
    And I should not see "Company10"

  @javascript
  Scenario: I18n translations
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

  @javascript
  Scenario: See all categories for each company
    Given I am Logged out
    And I am on the "landing" page
    And I should see "JustForFun"
    Then I select "Bowsers" in select list t("activerecord.models.company.one")
    And I click on t("search") button
    And I should see "Bowsers"
    And I should see "Groomer"
    And I should see "Trainer"
    And I should see "Rehab"
    And I should see "Psychologist"
    And I should not see "JustForFun"
