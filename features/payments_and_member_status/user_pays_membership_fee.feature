Feature: As a user
  So that I can be approved for membership
  I need to be able to pay my membership fee

  Background:
    Given the following users exist
      | email          | admin | is_member |
      | emma@mutts.com |       | false     |
      | admin@shf.se   | true  | true      |

    Given the following business categories exist
      | name         | description           |
      | rehab        | physical rehabitation |

    And the following applications exist:
      | user_email     | company_number | categories   | state        |
      | emma@mutts.com | 5562252998     | rehab        | under_review |

  @time_adjust
  Scenario: Set app state to accepted, User pays membership fee (2017)
    Given the date is set to "2017-10-01"

    When I am in "emma@mutts.com" browser
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    Then I should not see t("menus.nav.members.pay_membership")

    Then I am in "admin@shf.se" browser
    And I am logged in as "admin@shf.se"
    Then I am on the "application" page for "emma@mutts.com"
    And I click on t("membership_applications.accept_btn")

    Then I am in "emma@mutts.com" browser
    And I reload the page
    And I should see t("menus.nav.members.pay_membership")
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the payment
    And I should see t("payments.success.success")
    And I should see "2018-12-31"

  @time_adjust
  Scenario: Set app state to accepted, User pays membership fee (post-2017)
    Given the date is set to "2018-7-01"

    When I am in "emma@mutts.com" browser
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    Then I should not see t("menus.nav.members.pay_membership")

    Then I am in "admin@shf.se" browser
    And I am logged in as "admin@shf.se"
    Then I am on the "application" page for "emma@mutts.com"
    And I click on t("membership_applications.accept_btn")

    Then I am in "emma@mutts.com" browser
    And I reload the page
    And I should see t("menus.nav.members.pay_membership")
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the payment
    And I should see t("payments.success.success")
    And I should see "2019-06-30"
