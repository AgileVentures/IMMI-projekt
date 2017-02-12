Feature: So that I do not get frustrated by trying to find out more
  about a company that does not have complete information,
  Only show companies with complete information

  Background:
    Given the following regions exist:
      | name                  |
      | Stockholm             |
      | Västerbotten          |
      | ThisNameWillBeDeleted |

    And the following business categories exist
      | name    |
      | Groomer |
      | Trainer |


    Given the following companies exist:
      | name                     | company_number | email                  | region                | old_region   |
      | Happy Mutts              | 5560360793     | snarky@snarkybarky.com | Stockholm             | Stockholm    |
      | Bowsers                  | 2120000142     | bowwow@bowsersy.com    | Västerbotten          | Västerbotten |
      | NoRegion and NoOldRegion | 5562252998     | hello@noRegionOrOld.se | ThisNameWillBeDeleted |              |
      | NoOldRegion              | 5569467466     | hello@noOldRegion.se   | Stockholm             |              |
      | Only NoRegion            | 8028973322     | hello@onlyNoRegion.se  | ThisNameWillBeDeleted | Västerbotten |
      |                          | 5906055081     | hello@noName.se        | Stockholm             | Stockholm    |


    And the following users exists
      | email                        | admin |
      | admin@shf.se                 | true  |
      | emmaGroomer@happymutts.com   |       |
      | annaTrainer@bowsers.com      |       |
      | larsGroomer@noRegionOrOld.se |       |
      | larsTrainer@noRegionOrOld.se |       |
      | oleGroomer@noOldRegion.se    |       |
      | oleTrainer@noOldRegion.se    |       |
      | majaGroomer@onlyNoRegion.se  |       |
      | majaTrainer@onlyNoRegion.se  |       |
      | kikkiGroomer@noName.se       |       |
      | kikkiTrainer@noName.se       |       |


    And the following applications exist:
      | first_name   | user_email                   | company_number | category_name | state    |
      | EmmaGroomer  | emmaGroomer@happymutts.com   | 5560360793     | Groomer       | accepted |
      | AnnaTrainer  | annaTrainer@bowsers.com      | 2120000142     | Trainer       | accepted |
      | LarsGroomer  | larsGroomer@noRegionOrOld.se | 5562252998     | Groomer       | accepted |
      | LarsTrainer  | larsTrainer@noRegionOrOld.se | 5562252998     | Trainer       | accepted |
      | OleGroomer   | oleGroomer@noOldRegion.se    | 5569467466     | Groomer       | accepted |
      | OleTrainer   | oleTrainer@noOldRegion.se    | 5569467466     | Trainer       | accepted |
      | MajaGroomer  | majaGroomer@onlyNoRegion.se  | 8028973322     | Groomer       | accepted |
      | MajaTrainer  | majaTrainer@onlyNoRegion.se  | 8028973322     | Trainer       | accepted |
      | KikkiGroomer | kikkiGroomer@noName.se       | 5906055081     | Groomer       | accepted |
      | KikkiTrainer | kikkiTrainer@noName.se       | 5906055081     | Trainer       | accepted |

    And the region for company named "NoRegion and NoOldRegion" is set to nil
    And the old region for company named "NoRegion and NoOldRegion" is set to nil
    And the region for company named "Only NoRegion" is set to nil
    And the old region for company named "NoOldRegion" is set to nil


  @visitor
  Scenario: Visitor on landing page - only complete companies are shown
    Given I am Logged out
    And the region for company named "NoRegion and NoOldRegion" is set to nil
    And the old region for company named "NoRegion and NoOldRegion" is set to nil
    And I am on the "landing" page
    When I click on t("search") button
    Then I should see "Happy Mutts"
    And I should see "Bowsers"
    And I should see "NoOldRegion"
    And I should see "Only NoRegion"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5906055081"

  @visitor
  Scenario: Visitor on Kategori - only complete companies are shown
    Given I am Logged out
    When I am on the business category "Groomer"
    Then I should not see "5906055081"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5562252998"
    And I should not see "Bowsers"
    And I should not see "2120000142"
    And I should see "Happy Mutts"
    And I should see "NoOldRegion"
    And I should see "Only NoRegion"
    When I am on the business category "Trainer"
    Then I should not see "5906055081"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5562252998"
    And I should not see "Happy Mutts"
    And I should not see "5560360793"
    And I should see "Bowsers"
    And I should see "NoOldRegion"
    And I should see "Only NoRegion"


  @member
  Scenario: Member on landing page - only complete companies are shown
    Given I am logged in as "emmaGroomer@happymutts.com"
    When I am on the "landing" page
    Then I should see "Happy Mutts"
    And I should see "Bowsers"
    And I should see "NoOldRegion"
    And I should see "Only NoRegion"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5906055081"



  @member
  Scenario: Member on Kategori - only complete companies are shown
    Given I am logged in as "emmaGroomer@happymutts.com"
    When I am on the business category "Groomer"
    Then I should not see "5906055081"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5562252998"
    And I should not see "Bowsers"
    And I should not see "2120000142"
    And I should see "Happy Mutts"
    And I should see "NoOldRegion"
    And I should see "Only NoRegion"
    When I am on the business category "Trainer"
    Then I should not see "5906055081"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5562252998"
    And I should not see "Happy Mutts"
    And I should not see "5560360793"
    And I should see "Bowsers"
    And I should see "NoOldRegion"
    And I should see "Only NoRegion"


  @admin
  Scenario: admin is on companies list - only complete companies are shown
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should not see "5906055081"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5562252998"
    And I should see "Happy Mutts"
    And I should see "5560360793"
    And I should see "Bowsers"
    And I should see "2120000142"
    And I should see "NoOldRegion"
    And I should see "5569467466"
    And I should see "Only NoRegion"
    And I should see "8028973322"


  @admin
  Scenario: admin Kategori list - only complete companies are shown
    Given I am logged in as "admin@shf.se"
    When I am on the business category "Groomer"
    Then I should not see "5906055081"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5562252998"
    And I should not see "Bowsers"
    And I should not see "2120000142"
    And I should see "Happy Mutts"
    And I should see "NoOldRegion"
    And I should see "Only NoRegion"
    When I am on the business category "Trainer"
    Then I should not see "5906055081"
    And I should not see "NoRegion and NoOldRegion"
    And I should not see "5562252998"
    And I should not see "Happy Mutts"
    And I should not see "5560360793"
    And I should see "Bowsers"
    And I should see "NoOldRegion"
    And I should see "Only NoRegion"
