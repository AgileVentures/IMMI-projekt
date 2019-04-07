Feature: Search Companies

As a visitor to the site
In order to find companies that I might want to work with
I want to search for available companies by various criteria

Background:
  Given the following users exists
    | email                | admin | member |
    | fred@barkyboys.com   |       | true   |
    | john@happymutts.com  |       | true   |
    | anna@dogsrus.com     |       | true   |
    | emma@weluvdogs.com   |       | true   |
    | lars@nopayment.se    |       | true   |
    | admin@shf.se         | true  |        |

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
    | NoPayment   | 8028973322     | hello@nopayment.se   | Stockholm    | Alingsås  |
    | NoMember    | 9697222900     | hello@nomember.se    | Stockholm    | Alingsås  |

  And the following payments exist
    | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
    | fred@barkyboys.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
    | john@happymutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
    | anna@dogsrus.com    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5562252998     |
    | emma@weluvdogs.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5569467466     |

  And the following applications exist:
    | user_email          | company_number | state    | categories      |
    | fred@barkyboys.com  | 5560360793     | accepted | Groomer, Trainer|
    | john@happymutts.com | 2120000142     | accepted | Psychologist    |
    | anna@dogsrus.com    | 5562252998     | accepted | Trainer         |
    | emma@weluvdogs.com  | 5569467466     | accepted | Groomer, Walker |
    | lars@nopayment.se   | 8028973322     | accepted | Groomer, Trainer|

  Given the date is set to "2017-10-01"


@selenium @time_adjust
Scenario: View all searchable companies, sort by columns
  Given I am Logged out
  And I am on the "landing" page
  And I should see "Barky Boys"
  And I should see "HappyMutts"
  And I should see "Dogs R Us"
  And I should see "We Luv Dogs"
  And I should not see "NoPayment"
  And I should not see "NoMember"
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

@selenium @time_adjust
Scenario: Search by category
  Given I am Logged out
  And I am on the "landing" page
  And I should see "Barky Boys"
  And I should see "HappyMutts"
  And I should see "Dogs R Us"
  And I should see "We Luv Dogs"
  Then I select "Groomer" in select list t("activerecord.models.business_category.one")
  And I click on t("search")
  Then I click on t("accordion_label.company_search_form.hide")
  And I should see "Barky Boys"
  And I should see "We Luv Dogs"
  And I should not see "HappyMutts"
  And I should not see "Dogs R Us"
  And I should see "Trainer"
  And I should see "Walker"
  And I should not see "Psychologist"

@selenium @time_adjust
Scenario: Search by region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  Then I click on t("accordion_label.company_search_form.hide")
  Then I should see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  And I should not see "We Luv Dogs"

@selenium @time_adjust
Scenario: Search by company (and confirm non-admin cannot search with non-searchable company name)
  Given I am Logged out
  And I am on the "landing" page
  And I cannot select "NoPayment" in select list t("activerecord.models.company.one")
  And I cannot select "NoMember" in select list t("activerecord.models.company.one")
  Then I select "We Luv Dogs" in select list t("activerecord.models.company.one")
  And I click on t("search")
  Then I click on t("accordion_label.company_search_form.hide")
  And I should see "We Luv Dogs"
  And I should not see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"

@selenium @time_adjust
Scenario: Search by company (and confirm admin can search with all company names)
  Given I am logged in as "admin@shf.se"
  And I am on the "all companies" page
  And I select "NoPayment" in select list t("activerecord.models.company.one")
  And I click on t("search")
  And I should see "NoPayment"
  And I should not see "We Luv Dogs"
  And I reload the page
  And I select "NoMember" in select list t("activerecord.models.company.one")
  And I click on t("search")
  And I should see "NoMember"
  And I should not see "We Luv Dogs"
  And I should not see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  And I should not see "NoPayment"

@selenium @time_adjust
Scenario: Search by kommun and region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Alingsås" in select list t("activerecord.attributes.company.kommun")
  And I click on t("search")
  And I should not see "HappyMutts"
  And I should not see "We Luv Dogs"
  And I should see "Barky Boys"
  And I should not see "Dogs R Us"
  Then I select "Norrbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  And I should not see "HappyMutts"
  Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  And I should see "Barky Boys"

@selenium @time_adjust
Scenario: Search by category and region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Groomer" in select list t("activerecord.models.business_category.one")
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  And I should not see "HappyMutts"
  And I should not see "We Luv Dogs"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  And I should see "Barky Boys"
  Then I select "Sweden" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  And I should see "We Luv Dogs"

@selenium @time_adjust
Scenario: Search by region
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  Then I should see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  And I should not see "We Luv Dogs"

@selenium @time_adjust
Scenario: Search by company
  Given I am Logged out
  And I am on the "landing" page
  Then I select "We Luv Dogs" in select list t("activerecord.models.company.one")
  And I click on t("search")
  And I should see "We Luv Dogs"
  And I should not see "HappyMutts"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"

@selenium @time_adjust
Scenario: Search by kommun
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Alingsås" in select list t("activerecord.attributes.company.kommun")
  And I click on t("search")
  And I should see "Barky Boys"
  And I should not see "HappyMutts"
  And I should not see "We Luv Dogs"
  And I should not see "Dogs R Us"
  Then I select "Laxå" in select list t("activerecord.attributes.company.kommun")
  And I click on t("search")
  And I should see "Barky Boys"
  And I should not see "HappyMutts"
  And I should see "We Luv Dogs"
  And I should not see "Dogs R Us"

@selenium @time_adjust
Scenario: Search by category and region 2
  Given I am Logged out
  And I am on the "landing" page
  Then I select "Groomer" in select list t("activerecord.models.business_category.one")
  Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  And I should not see "HappyMutts"
  And I should not see "We Luv Dogs"
  And I should not see "Barky Boys"
  And I should not see "Dogs R Us"
  Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  And I should see "Barky Boys"
  Then I select "Sweden" in select list t("activerecord.attributes.company.region")
  And I click on t("search")
  And I should see "We Luv Dogs"

@selenium @time_adjust
Scenario: Toggle Hide/Show search form
  Given I am Logged out
  And I am on the "landing" page
  And I should see t("accordion_label.company_search_form.hide")
  And t("activerecord.models.company.one") should be visible
  Then I click on t("accordion_label.company_search_form.hide")
  Then I wait 2 seconds
  And I should see t("accordion_label.company_search_form.show")
  Then t("activerecord.models.company.one") should not be visible
