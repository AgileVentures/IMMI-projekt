Feature: Search Companies

As a visitor to the site
In order to find companies that I might want to work with
I want to search for available companies by various criteria

Background:
  Given the following users exists
    | email                | admin |
    | fred@barkyboys.com   |       |
    | john@happymutts.com  |       |
    | anna@dogsrus.com     |       |
    | emma@weluvdogs.com   |       |

  And the following business categories exist
    | name         |
    | Groomer      |
    | Psychologist |
    | Trainer      |
    | Walker       |

  Given the following regions exist:
    | name         |
    | Stockholm    |
    | Västerbotten |
    | Norrbotten   |
    | Sweden       |

  And the following companies exist:
    | name        | company_number | email                | region       | city        |
    | Barky Boys  | 5560360793     | barky@barkyboys.com  | Stockholm    | Bagarmossen |
    | HappyMutts  | 2120000142     | woof@happymutts.com  | Västerbotten | Kusmark     |
    | Dogs R Us   | 5562252998     | chief@dogsrus.com    | Norrbotten   | Morjarv     |
    | We Luv Dogs | 5569467466     | alpha@weluvdogs.com  | Sweden       |             |

  And the following applications exist:
    | first_name | user_email          | company_number | state    | category_name |
    | Fred       | fred@barkyboys.com  | 5560360793     | accepted | Groomer       |
    | John       | john@happymutts.com | 2120000142     | accepted | Psychologist  |
    | Anna       | anna@dogsrus.com    | 5562252998     | accepted | Trainer       |
    | Emma       | emma@weluvdogs.com  | 5569467466     | accepted | Groomer       |

@javascript
Scenario: Go to companies index page, see all companies, search by category
  Given I am Logged out
  And I am on the "landing" page
  And I should see "Barky Boys"
  And I should see "HappyMutts"
  And I should see "Dogs R Us"
  And I should see "We Luv Dogs"
  Then I select "Groomer" in select list t("activerecord.models.business_category.one")
  And I click on t("search") button
  And I should see "Barky Boys"
  And I should see "We Luv Dogs"
  And I should not see "HappyMutts"
  And I should not see "Dogs R Us"

@javascript
Scenario: Search by region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  Then I should see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  And I should not see "We Luv Dogs"

@javascript
Scenario: Search by company
  Given I am Logged out
  And I am on the "landing" page
  Then I select "We Luv Dogs" in select list t("activerecord.models.company.one")
  And I click on t("search") button
  And I should see "We Luv Dogs"
  And I should not see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"

@javascript
Scenario: Search by city and region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Kusmark" in select list t("activerecord.attributes.company.city")
  And I click on t("search") button
  And I should see "HappyMutts"
  And I should not see "HWe Luv Dogs"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  Then I select "Norrbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should not see "HappyMutts"
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should see "HappyMutts"

@javascript
Scenario: Search by category and region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Groomer" in select list t("activerecord.models.business_category.one")
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should not see "HappyMutts"
  And I should not see "We Luv Dogs"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should see "Barky Boys"
  Then I select "Sweden" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should see "We Luv Dogs"

@javascript
Scenario: Search by region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  Then I should see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  And I should not see "We Luv Dogs"

@javascript
Scenario: Search by company
  Given I am Logged out
  And I am on the "landing" page
  Then I select "We Luv Dogs" in select list t("activerecord.models.company.one")
  And I click on t("search") button
  And I should see "We Luv Dogs"
  And I should not see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"

@javascript
Scenario: Search by city and region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Kusmark" in select list t("activerecord.attributes.company.city")
  And I click on t("search") button
  And I should see "HappyMutts"
  And I should not see "HWe Luv Dogs"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  Then I select "Norrbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should not see "HappyMutts"
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should see "HappyMutts"

@javascript
Scenario: Search by category and region 2
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Groomer" in select list t("activerecord.models.business_category.one")
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should not see "HappyMutts"
  And I should not see "We Luv Dogs"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should see "Barky Boys"
  Then I select "Sweden" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should see "We Luv Dogs"

@javascript
Scenario: Toggle Hide/Show search form
  Given I am Logged out
  And I am on the "landing" page
  Then I should see t("companies.index.how_to_search")
  And I should see t("toggle.company_search_form.hide")
  And t("activerecord.models.company.one") should be visible
  Then I click on t("toggle.company_search_form.hide")
  Then I wait 2 seconds
  And I should see t("toggle.company_search_form.show")
  Then t("activerecord.models.company.one") should not be visible
