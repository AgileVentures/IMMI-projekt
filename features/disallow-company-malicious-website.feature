Feature: Don't allow malicious code in Company website value
  As a Member
  So that I cannot corrupt SHF
  Don't allow me to save malicious code in the company website field



  Background:
    Given the following users exists
      | first_name | email               | admin |
      | Emma       | emma@happymutts.com |       |
      | admin      | admin@shf.se        | true  |

    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |

    And the following kommuns exist:
      | name      |
      | Bromölla  |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |


    And the following applications exist:
      | user_email          | company_number | state    |
      | emma@happymutts.com | 5560360793     | accepted |



  Scenario Outline: Malicious website entry not accepted
    Given I am logged in as "emma@happymutts.com"
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.website_include_http") with "<malicious_entry>"
    And I click on t("submit") button
    Then I should not see "<malicious_part>"
    And I should see "<ok_part>"

    Scenarios:
      | malicious_entry                                    | malicious_part                               | ok_part       |
      | <script>alert('XSS!')</script>                     | <script>                                     | alert('XSS!') |
      | javascript://alert('XSS!')                         | javascript://                                | alert('XSS!') |
      | <meta%20http-equiv='refresh'%20content='0;'>       | <meta%20http-equiv='refresh'%20content='0;'> |               |
      | >'><script>alert('XSS)</script>&                   | <script>                                     |               |
      | '><STYLE>@import'javascript:alert('XSS')';</STYLE> | javascript                                   | alert('XSS')  |



  Scenario Outline: Cannot create a company with a malicious website
    Given I am logged in as "admin@shf.se"
    And I am on the "create a new company" page
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.street | companies.show.post_code | companies.show.city | companies.show.email |
      | Happy Mutts            | 5569467466                    | Ålstensgatan 4        | 123 45                   | Bromma              | kicki@gladajyckar.se |
    And I select "Stockholm" in select list t("companies.operations_region")
    And I select "Bromölla" in select list t("companies.show.kommun")
    And I fill in t("companies.website_include_http") with "<malicious_entry>"
    And I click on t("submit") button
    Then I should not see "<malicious_part>"
    And I should see "<ok_part>"

    Scenarios:
      | malicious_entry                                    | malicious_part                               | ok_part       |
      | <script>alert('XSS!')</script>                     | <script>                                     | alert('XSS!') |
      | javascript://alert('XSS!')                         | javascript://                                | alert('XSS!') |
      | <meta%20http-equiv='refresh'%20content='0;'>       | <meta%20http-equiv='refresh'%20content='0;'> |               |
      | >'><script>alert('XSS)</script>&                   | <script>                                     |               |
      | '><STYLE>@import'javascript:alert('XSS')';</STYLE> | javascript                                   | alert('XSS')  |


