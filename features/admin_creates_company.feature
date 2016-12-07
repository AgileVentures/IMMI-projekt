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
      | email                      | admin |
      | applicant_1@happymutts.com |       |
      | admin@shf.se               | true  |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    |

    And the following applications exist:
      | first_name | user_email                 | company_number | status   |
      | Emma       | applicant_1@happymutts.com | 5562252998     | Godkänd  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Awesome      |

  Scenario: Admin creates a company
    Given I am logged in as "admin@shf.se"
    When I am on the "create a new company" page
    And I fill in the form with data :
      | Företagsnamn | Org nr     | Gata           | Post nr | Ort    | Verksamhetslän | Email                | Webbsida                  |
      | Happy Mutts  | 5569467466 | Ålstensgatan 4 | 123 45  | Bromma | Stockholm      | kicki@gladajyckar.se | http://www.gladajyckar.se |
    And I click on "Submit"
    Then I should see "Företaget har skapats"
    And I should see "Happy Mutts"
    And I should see "123 45"
    And I should see "Bromma"



  Scenario Outline: Admin creates company - when things go wrong
    Given I am logged in as "admin@shf.se"
    When I am on the "create a new company" page
    And I fill in the form with data :
      | Företagsnamn | Org nr       | Email   | Telefon | Gata     | Post nr     | Ort   | Verksamhetslän | Webbsida  |
      | <name>       | <org_number> | <email> | <phone> | <street> | <post_code> | <city> | <region>       | <website> |
    When I click on "Submit"
    Then I should see <error>
    And I should see "Ett eller flera problem hindrade företaget från att skapas."

    Scenarios:
      | name        | org_number | phone      | street         | post_code | city   | region    | email                | website                   | error                                                                 |
      | Happy Mutts | 00         | 0706898525 | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@gladajyckar.se | http://www.gladajyckar.se | "Company number is the wrong length (should be 10 characters)"        |
      | Happy Mutts | 5562252998 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kickiimmi.nu         | http://www.gladajyckar.se | "Email is invalid"                                                    |
      | Happy Mutts | 5562252998 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@imminu         | http://www.gladajyckar.se | "Email is invalid"                                                    |
      | Happy Mutts | 5560360793 | 0706898525 | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@imminu.se      | http://www.gladajyckar.se | "Detta företag (org nr) finns redan i systemet." |


  Scenario: Admin edits a company
    Given I am logged in as "admin@shf.se"
    And I am on the edit company page for "5560360793"
    When I fill in the form with data :
      | Email                | Webbsida                     |
      | kicki@gladajyckar.se | http://www.snarkybarkbark.se |
    And I click on "Submit"
    Then I should see "Företaget har uppdaterats."
    And I should see "kicki@gladajyckar.se"
    And I should see "http://www.snarkybarkbark.se"

  Scenario Outline: Admin edits a company - when things go wrong (sad case)
    Given I am logged in as "admin@shf.se"
    And I am on the edit company page for "5560360793"
    And I fill in the form with data :
      | Företagsnamn | Org nr       | Email   | Telefon | Gata     | Post nr     | Ort   | Verksamhetslän | Webbsida  |
      | <name>       | <org_number> | <email> | <phone> | <street> | <post_code> | <city> | <region>       | <website> |
    When I click on "Submit"
    Then I should see <error>
    And I should see "Ett problem förhindrade uppdatering av företaget."

    Scenarios:
      | name        | org_number | phone      | street         | post_code | city   | region    | email                | website                   | error                                                          |
      | Happy Mutts | 00         | 0706898525 | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@gladajyckar.se | http://www.gladajyckar.se | "Company number is the wrong length (should be 10 characters)" |
      | Happy Mutts | 5560360793 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kickiimmi.nu         | http://www.gladajyckar.se | "Email is invalid"                                             |
      | Happy Mutts | 5560360793 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@imminu         | http://www.gladajyckar.se | "Email is invalid"                                             |

  Scenario: Admin sees all companies listed
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see "No More Snarky Barky"
    And I should see "Bowsers"

  Scenario: User tries to create a company
    Given I am logged in as "applicant_1@happymutts.com"
    And I am on the "create a new company" page
    Then I should see "Du har inte behörighet att göra detta."

  Scenario: Visitor tries to create a company
    Given I am Logged out
    And I am on the "create a new company" page
    Then I should see "Du har inte behörighet att göra detta."
