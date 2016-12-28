Feature: As a member
  So that visitors can see if my company offers services they might be interested in
  I need to be able to set a page that displays information about my company

  PT:  https://www.pivotaltracker.com/story/show/133081453

  Background:
    Given the following users exists
      | email               | admin | is_member |
      | emma@happymutts.com |       | true      |
      | admin@shf.se        | true  | true      |

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 2120000142     | snarky@snarkybarky.com |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Awesome      |

    And the following applications exist:
      | first_name | user_email          | company_number | status  | category_name |
      | Emma       | emma@happymutts.com | 5562252998     | Godkänd | Awesome       |

  Scenario: Member goes to company page after membership approval
    Given I am logged in as "emma@happymutts.com"
    And I am on the "edit my company" page for "emma@happymutts.com"
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.street | companies.show.post_code | companies.show.city | companies.show.email | companies.website_include_http |
      | Happy Mutts            | 5562252998                    | Ålstensgatan 4        | 123 45                   | Bromma              | kicki@gladajyckar.se | http://www.gladajyckar.se      |
    And I select "Stockholm" in select list t("companies.operations_region")
    And I click on t("submit")
    Then I should see t("companies.update.success")
    And I should see "Happy Mutts"
    And I should see "123 45"
    And I should see "Bromma"

  Scenario: Another tries to edit your company page (gets rerouted)
    Given I am logged in as "emma@happymutts.com"
    And I am on the "edit my company" page
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.street | companies.show.post_code | companies.show.city | companies.show.email | companies.website_include_http |
      | Happy Mutts            | 5562252998                    | Ålstensgatan 4        | 123 45                   | Bromma              | kicki@gladajyckar.se | http://www.gladajyckar.se      |
    And I select "Västerbotten" in select list t("companies.operations_region")
    And I click on t("submit")
    And I am Logged out
    And I am logged in as "applicant_2@random.com"
    And I am on the "edit my company" page for "emma@happymutts.com"
    Then I should be on the landing page
    And I should see t("errors.not_permitted")


  Scenario: User tries to go do company page (gets rerouted)
    Given I am logged in as "applicant_2@random.com"
    And I am on the "edit my company" page for "emma@happymutts.com"
    Then I should be on the landing page
    And I should see t("errors.not_permitted")
