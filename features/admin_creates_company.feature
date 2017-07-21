Feature: As an admin
  So that I can view and manage companies
  I need to be able to create them

  Companies are created when a membership application is approved. That
  will not have any user interaction, but we need to have companies
  exist and the admin needs to be able to see the list of them.

  This feature exercises what happens when a company is created and is the
  basis for a member being able to edit their company page.

  PT:  https://www.pivotaltracker.com/story/show/133081453

  Background:
    Given the following users exists
      | first_name | email                      | admin |
      | Emma       | applicant_1@happymutts.com |       |
      | Anna       | applicant_3@happymutts.com |       |
      | admin      | admin@shf.se               | true  |

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |

    Given the following kommuns exist:
      | name      |
      | Bromölla  |

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    | Norrbotten |

    And the following applications exist:
      | user_email                 | company_number | state    |
      | applicant_1@happymutts.com | 5560360793     | accepted |
      | applicant_3@happymutts.com | 2120000142     | accepted |


    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Awesome      |

  Scenario: Admin sees all companies listed
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see "No More Snarky Barky"
    And I should see "Bowsers"

  Scenario: User tries to create a company
    Given I am logged in as "applicant_1@happymutts.com"
    And I am on the "create a new company" page
    Then I should see t("errors.not_permitted")

  Scenario: Visitor tries to create a company
    Given I am Logged out
    And I am on the "create a new company" page
    Then I should see t("errors.not_permitted")

  Scenario: Admin creates a company
    Given I am logged in as "admin@shf.se"
    When I am on the "create a new company" page
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.street | companies.show.post_code | companies.show.city | companies.show.email | companies.website_include_http |
      | Happy Mutts            | 5569467466                    | Ålstensgatan 4        | 123 45                   | Bromma              | kicki@gladajyckar.se | http://www.gladajyckar.se      |
    And I select "Stockholm" in select list t("companies.operations_region")
    And I select "Bromölla" in select list t("companies.show.kommun")
    And I click on t("submit")
    Then I should see t("companies.create.success")
    And I should see "Happy Mutts"
    And I should see "123 45"
    And I should see "Bromma"
    And I should see "Bromölla"
    And the "http://www.gladajyckar.se" should go to "http://www.gladajyckar.se"

  Scenario Outline: Admin creates company - when things go wrong
    Given I am logged in as "admin@shf.se"
    When I am on the "create a new company" page
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.email | companies.telephone_number | companies.show.street | companies.show.post_code | companies.show.city | companies.website_include_http |
      | <name>                 | <org_number>                  | <email>              | <phone>                    | <street>              | <post_code>              | <city>              | <website>                      |
    And I select "<region>" in select list t("companies.operations_region")
    When I click on t("submit")
    Then I should see <error>
    And I should see t("companies.create.error")

    Scenarios:
      | name        | org_number | phone      | street         | post_code | city   | region       | email                | website                   | error                                                        |
      | Happy Mutts | 00         | 0706898525 | Ålstensgatan 4 | 123 45    | Bromma | Stockholm    | kicki@gladajyckar.se | http://www.gladajyckar.se | t("errors.messages.wrong_length", count: 10)                 |
      | Happy Mutts | 5562252998 |            | Ålstensgatan 4 | 123 45    | Bromma | Västerbotten | kickiimmi.nu         | http://www.gladajyckar.se | t("errors.messages.invalid")                                 |
      | Happy Mutts | 5562252998 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm    | kicki@imminu         | http://www.gladajyckar.se | t("errors.messages.invalid")                                 |
      | Happy Mutts | 5560360793 | 0706898525 | Ålstensgatan 4 | 123 45    | Bromma | Norrbotten   | kicki@imminu.se      | http://www.gladajyckar.se | t("activerecord.errors.models.company.company_number.taken") |


  Scenario: Admin edits a company
    Given I am logged in as "admin@shf.se"
    And I am on the edit company page for "5560360793"
    When I fill in the translated form with data:
      | companies.show.email | companies.website_include_http |
      | kicki@gladajyckar.se | http://www.snarkybarkbark.se   |
    And I click on t("submit")
    Then I should see t("companies.update.success")
    And I should see "kicki@gladajyckar.se"
    And the "http://www.snarkybarkbark.se" should go to "http://www.snarkybarkbark.se"


  Scenario Outline: Admin edits a company - when things go wrong (sad case)
    Given I am logged in as "admin@shf.se"
    And I am on the edit company page for "5560360793"
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.email | companies.telephone_number | companies.show.street | companies.show.post_code | companies.show.city | companies.website_include_http |
      | <name>                 | <org_number>                  | <email>              | <phone>                    | <street>              | <post_code>              | <city>              | <website>                      |
    And I select "<region>" in select list t("companies.operations_region")
    When I click on t("submit")
    Then I should see translated error <model_attribute> <error>
    And I should see t("companies.update.error")

    Scenarios:
      | name        | org_number | phone | street         | post_code | city   | region     | email        | website                   | model_attribute                       | error                   |
      | Happy Mutts | 5560360793 |       | Ålstensgatan 4 | 123 45    | Bromma | Stockholm  | kickiimmi.nu | http://www.gladajyckar.se | activerecord.attributes.company.email | errors.messages.invalid |
      | Happy Mutts | 5560360793 |       | Ålstensgatan 4 | 123 45    | Bromma | Norrbotten | kicki@imminu | http://www.gladajyckar.se | activerecord.attributes.company.email | errors.messages.invalid |


  Scenario Outline: Admin edits a company: company number is wrong length
    Given I am logged in as "admin@shf.se"
    And I am on the edit company page for "5560360793"
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.email | companies.telephone_number | companies.show.street | companies.show.post_code | companies.show.city | companies.website_include_http |
      | <name>                 | <org_number>                  | <email>              | <phone>                    | <street>              | <post_code>              | <city>              | <website>                      |
    And I select "<region>" in select list t("companies.operations_region")
    When I click on t("submit")
    Then I should see t("errors.messages.wrong_length.other", count: 10)

    Scenarios:
      | name        | org_number | phone      | street         | post_code | city   | region    | email                | website                   |
      | Happy Mutts | 00         | 0706898525 | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@gladajyckar.se | http://www.gladajyckar.se |


  Scenario: Website path is incomplete (does not include http://)
    Given I am logged in as "admin@shf.se"
    And I am on the edit company page for "5560360793"
    When I fill in the translated form with data:
      | companies.website_include_http |
      | www.snarkybarkbark.se          |
    And I click on t("submit")
    Then I should see t("companies.update.success")
    And the "www.snarkybarkbark.se" should go to "http://www.snarkybarkbark.se"

  Scenario: Website path is complete (includes http://)
    Given I am logged in as "admin@shf.se"
    And I am on the edit company page for "5560360793"
    When I fill in the translated form with data:
      | companies.website_include_http |
      | http://www.snarkybarkbark.se   |
    And I click on t("submit")
    Then I should see t("companies.update.success")
    And the "www.snarkybarkbark.se" should go to "http://www.snarkybarkbark.se"
