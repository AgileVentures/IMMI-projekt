Feature: Search Membership Applications

As an admin for the site
In order to find find and manage applications
I want to search for applications by various criteria

Background:
  Given the following users exists
    | email                | admin |
    | fred@barkyboys.com   |       |
    | john@happymutts.com  |       |
    | anna@dogsrus.com     |       |
    | emma@weluvdogs.com   |       |
    | admin@shf.se         | true  |

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
    | first_name | last_name  | user_email          | company_number | state        | category_name |
    | Fred       | Fransson   | fred@barkyboys.com  | 5560360793     | rejected     | Groomer       |
    | John       | Johanssen  | john@happymutts.com | 2120000142     | accepted     | Psychologist  |
    | Anna       | Anderson   | anna@dogsrus.com    | 5562252998     | new          | Trainer       |
    | Emma       | Eriksson   | emma@weluvdogs.com  | 5569467466     | under_review | Walker        |

  And I am logged in as "admin@shf.se"
  And I am on the "membership applications" page

@javascript
Scenario: Search by user's last name
  And I should see "Fred"
  And I should see "John"
  And I should see "Anna"
  And I should see "Emma"
  Then I select "Fransson" in select list t("activerecord.attributes.membership_application.last_name")
  And I click on t("search") button
  And I should see "Fransson, Fred"
  And I should not see "John"
  And I should not see "Anna"
  And I should not see "Emma"

@javascript
Scenario: Search by company (org) number
  Then I select "5569467466" in select list t("membership_applications.index.org_nr")
  And I click on t("search") button
  Then I should see "Eriksson, Emma"
  And I should not see "John"
  And I should not see "Anna"
  And I should not see "Fred"
  Then I select "2120000142" in select list t("membership_applications.index.org_nr")
  And I click on t("search") button
  Then I should see "Eriksson, Emma"
  Then I should see "Johanssen, John"

@javascript
Scenario: Search by status
  Then I select "Under review" in select list t("membership_applications.index.state")
  And I click on t("search") button
  And I should see "Eriksson, Emma"
  And I should not see "John"
  And I should not see "Anna"
  And I should not see "Fred"
  Then I select "New" in select list t("membership_applications.index.state")
  And I click on t("search") button
  And I should see "Eriksson, Emma"
  And I should see "Anderson, Anna"
  And I should not see "John"
  And I should not see "Fred"

@javascript
Scenario: Search by status and company number
  Then I select "Under review" in select list t("membership_applications.index.state")
  Then I select "2120000142" in select list t("membership_applications.index.org_nr")
  And I click on t("search") button
  And I should not see "Emma"
  And I should not see "John"
  And I should not see "Anna"
  And I should not see "Fred"
  Then I select "5569467466" in select list t("membership_applications.index.org_nr")
  And I click on t("search") button
  And I should see "Eriksson, Emma"
  And I should not see "John"
  And I should not see "Anna"
  And I should not see "Fred"
