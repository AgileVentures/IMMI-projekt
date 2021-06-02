Feature: Don't allow malicious code in Company website value
  As a Member
  So that I cannot corrupt SHF
  Don't allow me to save malicious code in the company website field


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email          | admin | membership_status | member |
      | emma@mutts.com |       | current_member    | true   |
      | admin@shf.se   | true  |                   |        |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |

    And the following kommuns exist:
      | name     |
      | Bromölla |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |


    And the following applications exist:
      | user_email     | company_number | state    |
      | emma@mutts.com | 5560360793     | accepted |


    And the following memberships exist:
      | email          | first_day | last_day   |
      | emma@mutts.com | 2017-10-1 | 2017-12-31 |

  # -----------------------------------------------------------------------------------------------

  @time_adjust
  Scenario Outline: Malicious website entry not accepted
    Given the date is set to "2017-10-01"
    Given I am logged in as "emma@mutts.com"
    And I am on the edit company page for "5560360793"
    And I fill in t("companies.website_include_http") with "<malicious_entry>"
    And I click on t("submit") button
    Then I should not see "<malicious_part>"
    And I should see "<ok_part>"

    Scenarios:
      | malicious_entry                                    | malicious_part                                     | ok_part       |
      | <script>alert('XSS!')</script>                     | <script>alert('XSS!')</script>                     |               |
      | javascript://alert('XSS!')                         | javascript://                                      | alert('XSS!') |
      | <meta%20http-equiv='refresh'%20content='0;'>       | <meta%20http-equiv='refresh'%20content='0;'>       |               |
      | >'><script>alert('XSS)</script>&                   | <script>                                           |               |
      | '><STYLE>@import'javascript:alert('XSS')';</STYLE> | '><STYLE>@import'javascript:alert('XSS')';</STYLE> |               |


  Scenario Outline: Cannot create a company with a malicious website
    Given I am logged in as "admin@shf.se"
    And I am on the "create a new company" page
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.email |
      | Happy Mutts            | 5569467466                    | kicki@gladajyckar.se |
    And I fill in t("companies.website_include_http") with "<malicious_entry>"
    And I click on t("submit") button
    Then I should not see "<malicious_part>"
    And I should see "<ok_part>"

    Scenarios:
      | malicious_entry                                    | malicious_part                                     | ok_part       |
      | <script>alert('XSS!')</script>                     | <script>alert('XSS!')</script>                     |               |
      | javascript://alert('XSS!')                         | javascript://                                      | alert('XSS!') |
      | <meta%20http-equiv='refresh'%20content='0;'>       | <meta%20http-equiv='refresh'%20content='0;'>       |               |
      | >'><script>alert('XSS)</script>&                   | <script>                                           |               |
      | '><STYLE>@import'javascript:alert('XSS')';</STYLE> | '><STYLE>@import'javascript:alert('XSS')';</STYLE> |               |
