Feature: Sort and search Companies

  As a visitor to the site
  In order to find companies that I might want to work with
  I need to be able to sort the list to find companies,
    AND (smell that this needs to be broken into separate features!)
  I need to be able to search for available companies by various criteria

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists
    Given the App Configuration is not mocked and is seeded

    Given the following users exist:
      | email               | admin | member | agreed_to_membership_guidelines |
      | fred@barkyboys.com  |       | true   | true                            |
      | john@happymutts.com |       | true   | true                            |
      | anna@dogsrus.com    |       | true   | true                            |
      | emma@weluvdogs.com  |       | true   | true                            |
      | lars@nopayment.se   |       | true   | true                            |
      | admin@shf.se        | true  |        |                                 |

    And the following business categories exist
      | name         | subcategories                    |
      | Groomer      | Groomer Subcat1, Groomer Subcat2 |
      | Psychologist | Psycho Subcat1                   |
      | Trainer      | Trainer Subcat1, Trainer Subcat2 |
      | Walker       | Walker Subcat1, Walker Subcat2   |

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
      | name        | company_number | email               | region       | kommun    | city           |
      | Barky Boys  | 5560360793     | barky@barkyboys.com | Stockholm    | Alingsås  | city1          |
      | DogCo_01    | 5634016009     | dogco_01@mail.com   | Stockholm    | Alingsås  | CITY1          |
      | DogCo_02    | 8471950124     | dogco_02@mail.com   | Stockholm    | Alingsås  | 'CITY1   '     |
      | HappyMutts  | 2120000142     | woof@happymutts.com | Västerbotten | Bromölla  | city2          |
      | Dogs R Us   | 5562252998     | chief@dogsrus.com   | Norrbotten   | Östersund | city3          |
      | We Luv Dogs | 5569467466     | alpha@weluvdogs.com | Sweden       | Laxå      | city4          |
      | NoPayment   | 8028973322     | hello@nopayment.se  | Stockholm    | Alingsås  | city5          |
      | NoMember    | 9697222900     | hello@nomember.se   | Stockholm    | Alingsås  | city6          |
      | New Company | 8248600598     | newco@newco.com     | Stockholm    | Alingsås  | ' space city ' |


    And the following applications exist:
      | user_email          | company_number         | state    | categories                                                          |
      | fred@barkyboys.com  | 5560360793, 5634016009 | accepted | Groomer, Groomer Subcat1, Groomer Subcat2, Trainer, Trainer Subcat2 |
      | john@happymutts.com | 2120000142, 8471950124 | accepted | Psychologist                                                        |
      | anna@dogsrus.com    | 5562252998             | accepted | Trainer, Trainer Subcat1, Trainer Subcat2                           |
      | emma@weluvdogs.com  | 5569467466, 8248600598 | accepted | Groomer, Walker                                                     |
      | lars@nopayment.se   | 8028973322             | accepted | Groomer, Trainer                                                    |

    And the following payments exist
      | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
      | fred@barkyboys.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | fred@barkyboys.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5634016009     |
      | fred@barkyboys.com  | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | john@happymutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | john@happymutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8471950124     |
      | john@happymutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | anna@dogsrus.com    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5562252998     |
      | anna@dogsrus.com    | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | emma@weluvdogs.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5569467466     |
      | emma@weluvdogs.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8248600598     |
      | emma@weluvdogs.com  | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |


    Given the date is set to "2017-10-01"

  # -------------------------------------------------------------------------------------


  @selenium @time_adjust
  Scenario: Visitor sees all current companies, can sort by region, name, kommun
    Given I am Logged out
    When I am on the "landing" page
    Then I should see "Barky Boys"
    And I should see "HappyMutts"
    And I should see "Dogs R Us"
    And I should see "We Luv Dogs"
    And I should not see "NoPayment"
    And I should not see "NoMember"

    When I click on t("activerecord.attributes.company.region") link
    Then I should see "Norrbotten" before "Stockholm"
    And I should see "Stockholm" before "Sweden"
    And I should see "Sweden" before "Västerbotten"

    When I click on t("activerecord.attributes.company.name") link
    Then I should see "Barky Boys" before "Dogs R Us"
    And I should see "Dogs R Us" before "HappyMutts"
    And I should see "HappyMutts" before "We Luv Dogs"

    When I click on t("activerecord.attributes.company.kommun") link
    Then I should see "Alingsås" before "Bromölla"
    And I should see "Bromölla" before "Laxå"
    And I should see "Laxå" before "Östersund"

  @selenium @time_adjust
  Scenario: Search by category
    Given I am Logged out
    When I am on the "landing" page
    Then I should see "Barky Boys" in the list of companies
    And I should see "HappyMutts" in the list of companies
    And I should see "Dogs R Us" in the list of companies
    And I should see "We Luv Dogs" in the list of companies

    When I select "Groomer" in select list t("activerecord.models.business_category.one")
    And I click on t("search")
    Then I should see "Barky Boys" in the list of companies
    And I should see "We Luv Dogs" in the list of companies
    And I should not see "HappyMutts" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    And I should see "Trainer" in the list of companies
    And I should see "Walker" in the list of companies
    And I should not see "Psychologist" in the list of companies

  @selenium @time_adjust
  Scenario: Search by subcategory
    Given I am Logged out
    When I am on the "landing" page
    Then I should see "Barky Boys" in the list of companies
    And I should see "HappyMutts" in the list of companies
    And I should see "Dogs R Us" in the list of companies
    And I should see "We Luv Dogs" in the list of companies

    When I select "Groomer Subcat1" in select list t("activerecord.models.business_category.one")
    And I click on t("search")
    Then I should see "Barky Boys" in the list of companies
    And I should see "DogCo_01" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies
    And I should not see "HappyMutts" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    And I should see "Trainer" in the list of companies
    And I should see "Groomer" in the list of companies
    And I should not see "Psychologist" in the list of companies
    And I should not see "Walker" in the list of companies

    When I select "Trainer Subcat2" in select list t("activerecord.models.business_category.one")
    And I click on t("search")
    Then I should see "Dogs R Us" in the list of companies

  @selenium @time_adjust
  Scenario: Search by region
    Given I am Logged out
    And I am on the "landing" page
    Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    Then I should see "HappyMutts" in the list of companies
    And I should not see "Barky Boys" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies

  @selenium @time_adjust
  Scenario: Search by company (and confirm non-admin cannot search with non-searchable company name)
    Given I am Logged out
    And I am on the "landing" page
    And I cannot select "NoPayment" in select list t("activerecord.models.company.one")
    And I cannot select "NoMember" in select list t("activerecord.models.company.one")
    Then I select "We Luv Dogs" in select list t("activerecord.models.company.one")
    And I click on t("search")
    And I should see "We Luv Dogs" in the list of companies
    And I should not see "HappyMutts" in the list of companies
    And I should not see "Barky Boys" in the list of companies
    And I should not see "Dogs R Us" in the list of companies

  @selenium @time_adjust
  Scenario: Search by company (and confirm admin can search with all company names)
    Given I am logged in as "admin@shf.se"
    And I am on the "all companies" page
    And I select "NoPayment" in select list t("activerecord.models.company.one")
    And I click on t("search")
    And I should see "NoPayment" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies
    And I reload the page
    And I select "NoMember" in select list t("activerecord.models.company.one")
    And I click on t("search")
    And I should see "NoMember"
    And I should not see "We Luv Dogs" in the list of companies
    And I should not see "HappyMutts" in the list of companies
    And I should not see "Barky Boys" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    And I should not see "NoPayment" in the list of companies

  @selenium @time_adjust
  Scenario: Search by kommun and region
    Given I am Logged out
    And I am on the "landing" page
    Then I select "Alingsås" in select list t("activerecord.attributes.company.kommun")
    And I click on t("search")
    And I should see "Barky Boys" in the list of companies
    And I should not see "HappyMutts" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    Then I select "Norrbotten" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    And I should not see "HappyMutts" in the list of companies

    And I reload the page

    Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    And I wait for all ajax requests to complete
    And I should see "Barky Boys" in the list of companies

  @selenium @time_adjust
  Scenario: Search by category and region
    Given I am Logged out
    And I am on the "landing" page
    Then I select "Groomer" in select list t("activerecord.models.business_category.one")
    Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    And I should not see "HappyMutts" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies
    And I should not see "Barky Boys" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    And I should see "Barky Boys"
    Then I select "Sweden" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    And I should see "We Luv Dogs"
    And I wait for all ajax requests to complete

  @selenium @time_adjust
  Scenario: Search by region
    Given I am Logged out
    And I am on the "landing" page
    Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    Then I should see "HappyMutts"
    And I should not see "Barky Boys" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies

  @selenium @time_adjust
  Scenario: Search by company
    Given I am Logged out
    And I am on the "landing" page
    Then I select "We Luv Dogs" in select list t("activerecord.models.company.one")
    And I click on t("search")
    And I should see "We Luv Dogs"
    And I should not see "HappyMutts" in the list of companies
    And I should not see "Barky Boys" in the list of companies
    And I should not see "Dogs R Us" in the list of companies

  @selenium @time_adjust
  Scenario: Search by kommun
    Given I am Logged out
    And I am on the "landing" page
    Then I select "Alingsås" in select list t("activerecord.attributes.company.kommun")
    And I click on t("search")
    And I should see "Barky Boys"
    And I should not see "HappyMutts" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    Then I select "Laxå" in select list t("activerecord.attributes.company.kommun")
    And I click on t("search")
    And I should see "Barky Boys"
    And I should not see "HappyMutts" in the list of companies
    And I should see "We Luv Dogs"
    And I should not see "Dogs R Us" in the list of companies

  @selenium @time_adjust
  Scenario: Search by category and region 2
    Given I am Logged out
    And I am on the "landing" page
    Then I select "Groomer" in select list t("activerecord.models.business_category.one")
    Then I select "Västerbotten" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    And I should not see "HappyMutts" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies
    And I should not see "Barky Boys" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    Then I select "Stockholm" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    And I should see "Barky Boys"
    Then I select "Sweden" in select list t("activerecord.attributes.company.region")
    And I click on t("search")
    And I should see "We Luv Dogs"
    And I should see "City4" in the list of companies

  @selenium @time_adjust
  Scenario: Toggle Hide/Show search form
    Given I am Logged out
    And I am on the "landing" page
    And I should see t("accordion_label.company_search_form.hide")
    And t("activerecord.models.company.one") should be visible
    Then I hide the companies search form
    Then I wait 2 seconds
    And I should see t("accordion_label.company_search_form.show")
    Then t("activerecord.models.company.one") should not be visible

  @selenium @time_adjust
  Scenario: Search by city
    Given I am Logged out
    And I am on the "landing" page
    Then I select "City1" in select list t("activerecord.attributes.company.city")
    And I click on t("search")
    And I should see "Barky Boys"
    And I should not see "HappyMutts" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies
    And I should not see "Dogs R Us" in the list of companies
    Then I select "City2" in select list t("activerecord.attributes.company.city")
    And I click on t("search")
    And I should see "HappyMutts"
    And I should see "Barky Boys"
    And I should not see "We Luv Dogs" in the list of companies

  @selenium @time_adjust
  Scenario: Search by city ignores case, and leading and trailing whitespace in city name
    Given I am Logged out
    And I am on the "landing" page
    When I select "Space City" in select list t("activerecord.attributes.company.city")
    And I click on t("search")
    Then I should see "New Company"
    And I should not see "HappyMutts" in the list of companies
    And I should not see "We Luv Dogs" in the list of companies
    And I should not see "Dogs R Us" in the list of companies

    When I select "City1" in select list t("activerecord.attributes.company.city")
    And I click on t("search")
    Then I should see "Barky Boys"
    And I should see "DogCo_01"
    And I should see "DogCo_02"
    And I should see "City1" 3 times in the list of companies
