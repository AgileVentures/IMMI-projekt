Feature: As any type of visitor
  In order to easily find a company of a certain category
  I should be able to see the companies of that category listed
  PT: https://www.pivotaltracker.com/story/show/135684057

  Background:
    Given the following users exists
      | email               | admin | is_member |
      | emma@happymutts.com |       | true      |
      | anna@sadmutts.com   |       | true      |
      | ernt@mutts.com      |       | true      |
      | admin@shf.se        | true  | true      |

    And the following companies exist:
      | name                 | company_number | email               |
      | No More Snarky Barky | 5562252998     | emma@happymutts.com |
      | WOOF                 | 5569467466     | ernt@mutts.com      |
      | Sad Sad Snarky Barky | 2120000142     | anna@sadmutts.com   |

    And the following business categories exist
      | name    |
      | Awesome |
      | Sadness |
      | Goodies |
      | Extra   |

    And the following applications exist:
      | first_name | user_email          | company_number | status  | category_name |
      | Emma       | emma@happymutts.com | 5562252998     | Godkänd | Awesome       |
      | Ernt       | ernt@mutts.com      | 5569467466     | Godkänd | Awesome       |
      | Anna       | anna@sadmutts.com   | 2120000142     | Godkänd | Sadness       |

  Scenario: Categories list multiple businesses
    Given I am Logged out
    And I am on the business category "Awesome"
    Then I should see "No More Snarky Barky"
    And I should see "WOOF"
    And I should not see "Sad Sad Snarky Barky"

  Scenario: Categories list businesses
    Given I am Logged out
    And I am on the business category "Sadness"
    Then I should not see "No More Snarky Barky"
    And I should see "Sad Sad Snarky Barky"
    When I am logged in as "anna@sadmutts.com "
    And I am on the business category "Sadness"
    Then I should not see "No More Snarky Barky"
    And I should see "Sad Sad Snarky Barky"

  Scenario: Categories list no businesses
    Given I am Logged out
    And I am on the business category "Goodies"
    Then I should see t("business_categories.show.no_one_applied_category")
    And I should not see "No More Snarky Barky"
    And I should not see "Sad Sad Snarky Barky"

  Scenario: Another category is added
    Given I am logged in as "admin@shf.se"
    And I am on the "edit my application" page for "ernt@mutts.com"
    And I select "Extra" Category
    And I click on t("membership_applications.edit.submit_button_label")
    When I am on the business category "Extra"
    Then I should see "WOOF"
