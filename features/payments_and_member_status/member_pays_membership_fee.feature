Feature: Member pays membership fee

  As a member
  So that I can get or renew my membership
  I need to be able to pay my membership fee

  Background:
    Given the App Configuration is not mocked and is seeded
    And the grace period is 0 years, 0 months, and 4 days

    And the Membership Ethical Guidelines Master Checklist exists

    Given the date is set to "2018-01-01"

    Given the following users exist:
      | email                    | admin | membership_status | member | membership_number | agreed_to_membership_guidelines |
      | emma@mutts.com           |       | current_member    | true   | 1001              | true                            |
      | overdue-member@mutts.com |       | in_grace_period   | false  | 1002              | true                            |
      | admin@shf.se             | true  |                   | false  |                   |                                 |


    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email               | company_number | state    |
      | emma@mutts.com           | 2120000142     | accepted |
      | overdue-member@mutts.com | 2120000142     | accepted |

    Given the following payments exist
      | user_email               | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com           | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |
      | overdue-member@mutts.com | 2017-01-1  | 2017-12-31  | member_fee   | betald | none    |

    Given these files have been uploaded:
      | user_email               | file name | description                               |
      | emma@mutts.com           | image.png | Image of a class completion certification |
      | overdue-member@mutts.com | image.png | Image of a class completion certification |

    Given the following memberships exist:
      | email                    | first_day | last_day   |
      | emma@mutts.com           | 2018-01-1 | 2018-12-31 |
      | overdue-member@mutts.com | 2018-01-1 | 2018-12-31 |

  # -----------------------------------------------------------------------------------------------


  @time_adjust
  Scenario: Member pays membership fee after term expires (in grace pd)
    Given the date is set to "2019-01-02"
    And I am logged in as "emma@mutts.com"
    And I have met all the non-payment requirements for renewing my membership
    And I am on the "user account" page
    Then I should see t("users.renewal.renewal_overdue_warning")
    When I click on t("users.renewal.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And my membership expiration date should be 2020-01-01
    And I should be a current member


  @time_adjust
  Scenario: Member pays fee before term expires and extends membership
    Given the date is set to "2018-12-01"
    And I am logged in as "emma@mutts.com"
    And my membership expiration date should be 2018-12-31
    And I have met all the non-payment requirements for membership
    When I am on the "user account" page
    Then I should see "2018-12-31"
    Then the link button t("users.show.pay_membership") should not be disabled


  @selenium
  Scenario: Member starts payment process then abandons it so no payment is made
    Given the date is set to "2018-12-30"
    And I am logged in as "emma@mutts.com"
    When I am on the "user account" page
    Then I should see "1001"
    When I click on t("menus.nav.members.pay_membership")
    And I abandon the payment by going back to the previous page
    Then I should not see t("payments.success.success")
    And my membership expiration date should be 2018-12-31


  Scenario: Member incurs error in payment processing so no payment is made
    Given the date is set to "2018-12-30"
    And I am logged in as "emma@mutts.com"
    When I am on the "user account" page
    Then I should see "1001"
    When I click on t("menus.nav.members.pay_membership")
    And I incur an error in payment processing
    Then I should see t("payments.error.error")
    And my membership expiration date should be 2018-12-31
