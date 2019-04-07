Feature: As a member
  So that I can maintain my membership
  I need to be able to pay my membership fee
  And so that I can be sure that the map search is secure
  And I need to see the GeoTrust SSL certificate Image

  PivotalTracker https://www.pivotaltracker.com/story/show/162063275

  Background:
    Given the date is set to "2017-01-10"
    Given the following users exist
      | email          | admin | member    | membership_number |
      | emma@mutts.com |       | true      | 1001              |
      | admin@shf.se   | true  | false     |                   |

    Given the following companies exist:
      | name       | company_number | email                 | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com   | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | state    |
      | emma@mutts.com | 2120000142     | accepted |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

  @time_adjust
  Scenario: Member pays membership fee after prior payment expiration date
    Given the date is set to "2018-02-12"
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I should see "1001"
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And I should see "2019-02-11"

  @time_adjust
  Scenario: Member pays fee and extends membership
    Given the date is set to "2017-12-01"
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I should see "1001"
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And I should see "2018-12-31"

  @time_adjust
  Scenario: Membership expires and member cannot edit company
    Given the date is set to "2017-10-01"
    And I am logged in as "emma@mutts.com"
    And I am on the page for company number "2120000142"
    And I should see t("companies.edit_company")
    And I should see t("companies.show.add_address")
    And I am logged out
    Then the date is set to "2018-01-01"
    And I am logged in as "emma@mutts.com"
    And I am on the page for company number "2120000142"
    And I should not see t("companies.edit_company")
    And I should not see t("companies.show.add_address")

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

  @geoimg
  Scenario:
    Given I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I should see "1001"
    And I click on t("menus.nav.members.pay_membership")
    Then I should see xpath "//img[contains(@src,'RapidSSL_SEAL-90x50')]"
    And when I click image via xpath "//img[contains(@src,'RapidSSL_SEAL-90x50')]"
    Then I should be on page "https://www.rapidssl.com/about/"
    And I should see xpath "//img[contains(@src,'rapidssl_ssl_certificate.gif')]"
