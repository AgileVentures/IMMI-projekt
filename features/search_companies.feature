Feature: Search Companies

As an SHF user
In order to find companies that I might want to work with
I want to search available companies by various criteria

Background:
  Given the following users exists
    | email                | admin | is_member |
    | fred@barkyboys.com   |       | true      |
    | john@happymutts.com  |       | true      |
    | anna@dogsrus.com     |       | true      |
    | emma@weluvdogs.com   |       | true      |

  And the following business categories exist
    | name         |
    | Groomer      |
    | Psychologist |
    | Trainer      |

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
    | first_name | user_email          | company_number | status  | category_name |
    | Fred       | fred@barkyboys.com  | 5560360793     | Godkänd | Groomer       |
    | John       | john@happymutts.com | 2120000142     | Godkänd | Psychologist  |
    | Anna       | anna@dogsrus.com    | 5562252998     | Godkänd | Trainer       |
    | Emma       | emma@weluvdogs.com  | 5569467466     | Godkänd | Groomer       |

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
=======
  And show me the page

@javascript
Scenario: Search by region
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Search Jobs" button
  And I fill in "Description contains any" with "Job1., Job3."
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should see "Job3"
  And I should not see "Job2"
  And I should not see "Job4"

@javascript
Scenario: Search by company
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Search Jobs" button
  And I select "Skill1" in select list "Skills"
  And I select "Skill3" in select list "Skills"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should see "Job3"
  And I should see "Job2"
  And I should not see "Job4"

@javascript
Scenario: Search by city
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Search Jobs" button
  And I select "city1" in select list "City"
  And I select "city4" in select list "City"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should see "Job4"
  And I should not see "Job2"
  And I should not see "Job3"

@javascript
Scenario: Search by category and region
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Search Jobs" button
  And I fill in "Title contains all" with "Job4"
  And I fill in "Description contains any" with "Job1., Job2, Job3."
  And I click the "Search Jobs" button
  Then I should not see "Job1"
  And I should not see "Job3"
  And I should not see "Job2"
  And I should not see "Job4"
  And I fill in "Title contains all" with "Job1"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should not see "Job3"
  And I should not see "Job2"
  And I should not see "Job4"

@javascript
Scenario: Search by category and city
  Given I am on the home page
  And I click the "Jobs" link
  And I click the "Search Jobs" button
  And I select "Widgets Inc." in select list "Company"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should see "Job2"
  And I should not see "Job3"
  And I should not see "Job4"
  Then I select "Feature Inc." in select list "Company"
  And I click the "Search Jobs" button
  Then I should see "Job1"
  And I should see "Job2"
  And I should see "Job3"
  And I should see "Job4"
