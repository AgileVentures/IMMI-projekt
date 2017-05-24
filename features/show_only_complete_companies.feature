Feature: So that I do not get frustrated by trying to find out more
  about a company that does not have complete information,
  Only show companies with complete information

  Background:
    Given the following regions exist:
      | name                  |
      | Stockholm             |
      | Västerbotten          |
      | ThisNameWillBeDeleted |

    Given the following kommuns exist:
      | name      |
      | Alingsås  |
      | Bromölla  |
      | Laxå      |

    And the following business categories exist
      | name    |
      | Groomer |
      | Trainer |


    Given the following companies exist:
      | name         | company_number | email                  | region                | kommun   |
      | Happy Mutts  | 5560360793     | snarky@snarkybarky.com | Stockholm             | Alingsås |
      | Bowsers      | 2120000142     | bowwow@bowsersy.com    | Västerbotten          | Bromölla |
      | NoRegion     | 8028973322     | hello@NoRegion.se      | ThisNameWillBeDeleted | Laxå     |
      |              | 5906055081     | hello@noName.se        | Stockholm             | Alingsås |

    And the following users exists
      | email                        | admin |
      | admin@shf.se                 | true  |
      | emmaGroomer@happymutts.com   |       |
      | annaTrainer@bowsers.com      |       |
      | larsGroomer@noRegionOrOld.se |       |
      | larsTrainer@noRegionOrOld.se |       |
      | ole@noOldRegion.se           |       |
      | maja@onlyNoRegion.se         |       |
      | kikki@noName.se              |       |


    And the following applications exist:
      | first_name  | user_email                 | company_number | category_name    | state    |
      | EmmaGroomer | emmaGroomer@happymutts.com | 5560360793     | Groomer          | accepted |
      | AnnaTrainer | annaTrainer@bowsers.com    | 2120000142     | Trainer          | accepted |
      | Ole         | ole@noOldRegion.se         | 5569467466     | Groomer, Trainer | accepted |
      | Maja        | maja@onlyNoRegion.se       | 8028973322     | Groomer, Trainer | accepted |
      | Kikki       | kikki@noName.se            | 5906055081     | Groomer, Trainer | accepted |

    And the region for company named "NoRegion" is set to nil


  @visitor
  Scenario: Visitor on landing page - only complete companies are shown
    Given I am Logged out
    And the region for company named "NoRegion" is set to nil
    And I am on the "landing" page
    When I click on t("search") button
    Then I should see "Happy Mutts"
    And I should see "Bowsers"
    And I should not see "NoRegion"
    And I should not see "5906055081"

  @visitor
  Scenario: Visitor on Kategori - only complete companies are shown
    Given I am Logged out
    When I am on the business category "Groomer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Bowsers"
    And I should not see "2120000142"
    And I should see "Happy Mutts"
    When I am on the business category "Trainer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Happy Mutts"
    And I should not see "5560360793"
    And I should see "Bowsers"

  @member
  Scenario: Member on landing page - only complete companies are shown
    Given I am logged in as "emmaGroomer@happymutts.com"
    When I am on the "landing" page
    Then I should see "Happy Mutts"
    And I should see "Bowsers"
    And I should not see "NoRegion"
    And I should not see "5906055081"

  @member
  Scenario: Member on Kategori - only complete companies are shown
    Given I am logged in as "emmaGroomer@happymutts.com"
    When I am on the business category "Groomer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Bowsers"
    And I should not see "2120000142"
    And I should see "Happy Mutts"
    When I am on the business category "Trainer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Happy Mutts"
    And I should not see "5560360793"
    And I should see "Bowsers"

  @admin
  Scenario: admin is on companies list - only complete companies are shown
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should see "Happy Mutts"
    And I should see "5560360793"
    And I should see "Bowsers"
    And I should see "2120000142"
    And I should see "5569467466"


  @admin
  Scenario: admin Kategori list - only complete companies are shown
    Given I am logged in as "admin@shf.se"
    When I am on the business category "Groomer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Bowsers"
    And I should not see "2120000142"
    And I should see "Happy Mutts"
    When I am on the business category "Trainer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Happy Mutts"
    And I should not see "5560360793"
    And I should see "Bowsers"
