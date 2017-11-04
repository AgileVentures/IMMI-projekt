Feature: As a member
  So that I can maintain my membership
  I need to be able to pay my membership fee

  Background:
    Given the following users exist
      | email          | admin | is_member | membership_number |
      | emma@mutts.com |       | true      | 1001              |
      | admin@shf.se   | true  | true      | 1                 |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

  Scenario: Member pays fee and extends membership
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I should see "1001"
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the payment
    And I should see t("payments.success.success")
    And I should see "2018-12-31"

  @selenium
  Scenario: Member starts payment process then abandons it
    Given I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I should see "1001"
    Then I click on t("menus.nav.members.pay_membership")
    And I abandon the payment
    And I should see "2017-12-31"
    And I should not see t("payments.success.success")
    And I should not see "2018-12-31"

  Scenario: Member incurs error in payment processing
    Given I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I should see "1001"
    Then I click on t("menus.nav.members.pay_membership")
    And I incur an error in payment processing
    And I should see t("payments.error.error")
    And I should see "2017-12-31"
    And I should not see "2018-12-31"
