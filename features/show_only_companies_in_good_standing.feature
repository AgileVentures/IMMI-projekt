Feature: Visitors see only companies in good standing with complete information

  As a visitor I only want to see companies that are in good standing with SHF
  so that I do not work with any companies or members of those companies
    that have not met all of the requirements for being a member,
    including paying their fees,

  And I only want to see companies with all of the information needed
    so that I can contact them,

  Visitors should only see companies in good standing with complete information.


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

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
      | NoPayment    | 5562252998     | hello@nopayment.se     | Stockholm             | Alingsås |
      | NoMember     | 9697222900     | hello@nomember.se      | Stockholm             | Alingsås |

    And the following users exist:
      | email                        | admin | member | agreed_to_membership_guidelines |
      | emmagroomer@happymutts.com   |       | true   | true                            |
      | annatrainer@bowsers.com      |       | true   | true                            |
      | ole@noOldRegion.se           |       | true   | true                            |
      | maja@onlyNoRegion.se         |       | true   | true                            |
      | kikki@noName.se              |       | true   | true                            |
      | lars@nopayment.se            |       | true   | true                            |
      | larsTrainer@noRegionOrOld.se |       | true   | true                            |
      | admin@shf.se                 | true  | false  |                                 |

    And the following applications exist:
      | user_email                 | company_number | categories       | state    |
      | emmagroomer@happymutts.com | 5560360793     | Groomer          | accepted |
      | annatrainer@bowsers.com    | 2120000142     | Trainer          | accepted |
      | ole@noOldRegion.se         | 5569467466     | Groomer, Trainer | accepted |
      | maja@onlyNoRegion.se       | 8028973322     | Groomer, Trainer | accepted |
      | kikki@noName.se            | 5906055081     | Groomer, Trainer | accepted |
      | lars@nopayment.se          | 5562252998     | Groomer, Trainer | accepted |

    And the following payments exist
      | user_email                  | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emmagroomer@happymutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | emmagroomer@happymutts.com  | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | annatrainer@bowsers.com     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | annatrainer@bowsers.com     | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | admin@shf.se                | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9697222900     |

    Given the date is set to "2017-10-01"
    And the region for company named "NoRegion" is set to nil


  @visitor @time_adjust
  Scenario: Visitor on landing page - only searchable companies are shown
    Given I am Logged out
    And I am on the "landing" page
    When I click on t("search") button
    Then I should see "Happy Mutts"
    And I should see "Bowsers"
    And I should not see "NoRegion"
    And I should not see "5906055081"
    And I should not see "NoPayment"
    And I should not see "NoMember"

  @visitor @time_adjust
  Scenario: Visitor on Kategori - only searchable companies are shown
    Given I am Logged out
    When I am on the business category "Groomer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Bowsers"
    And I should not see "2120000142"
    And I should not see "NoPayment"
    And I should not see "NoMember"
    And I should see "Happy Mutts"
    When I am on the business category "Trainer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Happy Mutts"
    And I should not see "5560360793"
    And I should not see "NoPayment"
    And I should not see "NoMember"
    And I should see "Bowsers"

  @member @time_adjust
  Scenario: Member on landing page - only searchable companies are shown
    Given I am logged in as "emmagroomer@happymutts.com"
    When I am on the "landing" page
    Then I should see "Happy Mutts"
    And I should see "Bowsers"
    And I should not see "NoRegion"
    And I should not see "5906055081"
    And I should not see "NoPayment"
    And I should not see "NoMember"

  @member @time_adjust
  Scenario: Member on Kategori - only searchable companies are shown
    Given I am logged in as "emmagroomer@happymutts.com"
    When I am on the business category "Groomer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Bowsers"
    And I should not see "2120000142"
    And I should not see "NoPayment"
    And I should not see "NoMember"
    And I should see "Happy Mutts"
    When I am on the business category "Trainer"
    Then I should not see "5906055081"
    And I should not see "NoRegion"
    And I should not see "Happy Mutts" in the business categories table
    And I should not see "5560360793"
    And I should not see "NoPayment"
    And I should not see "NoMember"
    And I should see "Bowsers"

  @admin @time_adjust
  Scenario: admin is on companies list - all companies are shown
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see "5906055081"
    And I should not see "NoRegion"
    And I should see "Happy Mutts"
    And I should see "5560360793"
    And I should see "Bowsers"
    And I should see "2120000142"
    And I should see "5569467466"
    And I should see "NoPayment"
    And I should see "NoMember"

  @admin @time_adjust
  Scenario: admin Kategori list - all companies are shown
    Given I am logged in as "admin@shf.se"
    When I am on the business category "Groomer"
    And I should see "NoRegion"
    And I should see "Happy Mutts"
    And I should see "NoPayment"
    When I am on the business category "Trainer"
    And I should see "NoRegion"
    And I should see "Bowsers"
    And I should see "NoPayment"
