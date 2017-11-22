Feature: As a member
  So that my company can maintain my H-branding license rights
  I need to be able to pay my branding fee

  Background:
    Given the following users exist
      | email          | admin | is_member | membership_number |
      | emma@mutts.com |       | true      | 1001              |
      | admin@shf.se   | true  | true      | 1                 |

    Given the following companies exist:
      | name       | company_number | email                 | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com   | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | category_name | state    |
      | emma@mutts.com | 2120000142     | rehab         | accepted |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | branding_fee | betald | none    | 2120000142     |

  Scenario: Member pays branding fee and extends license period
    Given I am logged in as "emma@mutts.com"
    Then I am the page for company number "2120000142"
    And I should see "HappyMutts"
    Then I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "HappyMutts"
    And I should see t("payments.success.success")
    And I should see "2018-12-31"

  @selenium
  Scenario: Member starts payment process then abandons it
    Given I am logged in as "emma@mutts.com"
    Then I am the page for company number "2120000142"
    And I should see "HAPPYMUTTS"
    Then I click on t("menus.nav.company.pay_branding_fee")
    And I abandon the payment
    And I should see "2017-12-31"
    And I should not see t("payments.success.success")
    And I should not see "2018-12-31"

  Scenario: Member incurs error in payment processing
    Given I am logged in as "emma@mutts.com"
    Then I am the page for company number "2120000142"
    And I should see "HappyMutts"
    Then I click on t("menus.nav.company.pay_branding_fee")
    And I incur an error in branding payment processing for "HappyMutts"
    And I should see t("payments.error.error")
    And I should see "2017-12-31"
    And I should not see "2018-12-31"
