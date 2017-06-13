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

  Given the following kommuns exist:
    | name      |
    | Alingsås  |
    | Bromölla  |
    | Laxå      |
    | Östersund |

  And the following companies exist:
    | name        | company_number | email                | region       | kommun    |
    | Barky Boys  | 5560360793     | barky@barkyboys.com  | Stockholm    | Alingsås  |
    | HappyMutts  | 2120000142     | woof@happymutts.com  | Västerbotten | Bromölla  |
    | Dogs R Us   | 5562252998     | chief@dogsrus.com    | Norrbotten   | Östersund |
    | We Luv Dogs | 5569467466     | alpha@weluvdogs.com  | Sweden       | Laxå      |

  And the following applications exist:
    | first_name | user_email          | company_number | state    | categories      |
    | Fred       | fred@barkyboys.com  | 5560360793     | accepted | Groomer, Trainer|
    | John       | john@happymutts.com | 2120000142     | accepted | Psychologist    |
    | Anna       | anna@dogsrus.com    | 5562252998     | accepted | Trainer         |
    | Emma       | emma@weluvdogs.com  | 5569467466     | accepted | Groomer, Walker |

@javascript
Scenario: View all companies, sort by columns
  Given I am Logged out
  And I am on the "landing" page
  And I should see "Barky Boys"
  And I should see "HappyMutts"
  And I should see "Dogs R Us"
  And I should see "We Luv Dogs"
  And I click on t("activerecord.attributes.company.region") link
  And I should see "Norrbotten" before "Stockholm"
  And I should see "Stockholm" before "Sweden"
  And I should see "Sweden" before "Västerbotten"
  And I click on t("activerecord.attributes.company.name") link
  And I should see "Barky Boys" before "Dogs R Us"
  And I should see "Dogs R Us" before "HappyMutts"
  And I should see "HappyMutts" before "We Luv Dogs"
  And I click on t("activerecord.attributes.company.kommun") link
  And I should see "Alingsås" before "Bromölla"
  And I should see "Bromölla" before "Laxå"
  And I should see "Laxå" before "Östersund"

@javascript
Scenario: Search by category
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
  And I should see "Trainer"
  And I should see "Walker"
  And I should not see "Psychologist"

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
Scenario: Search by kommun and region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Alingsås" in select list t("activerecord.attributes.company.kommun")
  And I click on t("search") button
  And I should not see "HappyMutts"
  And I should not see "We Luv Dogs"
  And I should see "Barky Boys"
  And I should not see "Dogs R Us"
  Then I select "Norrbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should not see "HappyMutts"
  Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
  And I click on t("search") button
  And I should see "Barky Boys"

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
Scenario: Search by kommun
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Alingsås" in select list t("activerecord.attributes.company.kommun")
  And I click on t("search") button
  And I should see "Barky Boys"
  And I should not see "HappyMutts"
  And I should not see "We Luv Dogs"
  And I should not see "Dogs R Us"
  Then I select "Laxå" in select list t("activerecord.attributes.company.kommun")
  And I click on t("search") button
  And I should see "Barky Boys"
  And I should not see "HappyMutts"
  And I should see "We Luv Dogs"
  And I should not see "Dogs R Us"

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
