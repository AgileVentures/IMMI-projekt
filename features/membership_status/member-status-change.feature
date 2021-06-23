Feature: Membership status updated due to payments or expiration

  As a member
  So that my membership status is always current and accurate
  The system must review dates, payments, and actions nightly

  Membership application state, membership payments, and H-branding (license) payments
  all affect membership status.
  The particular date also affects status:  has a membership expired?
  These all need to accurately change membership status.

  Background:

    Given the App Configuration is not mocked and is seeded
    And the grace period is 0 years, 0 months, and 4 days

    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | email                             | admin | membership_status | member | membership_number | agreed_to_membership_guidelines |
      | emma@mutts.com                    |       | current_member    | true   | 1001              | true                            |
      | bob-former-member@snarkybarky.com |       | former_member     | true   | 1002              | true                            |
      | lars@newapp.com                   |       | not_a_member      | false  |                   | true                            |
      | admin@shf.se                      | true  |                   | false  |                   |                                 |

    Given the following companies exist:
      | name                 | company_number | email                  | region    |
      | HappyMutts           | 2120000142     | woof@happymutts.com    | Stockholm |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm |
      | LarsCo               | 5562252998     | lars@newapp.com        | Stockholm |

    Given the following applications exist:
      | user_email                        | company_number | category_name | state    |
      | emma@mutts.com                    | 2120000142     | rehab         | accepted |
      | bob-former-member@snarkybarky.com | 5560360793     | grooming      | accepted |
      | lars@newapp.com                   | 5562252998     | rehab         | new      |


    Given the following memberships exist:
      | email                             | first_day  | last_day   |
      | emma@mutts.com                    | 2017-12-31 | 2018-12-31 |
      | bob-former-member@snarkybarky.com | 2012-01-01 | 2012-12-31 |


    Given the date is set to "2017-12-31"

    Given the following payments exist
      | user_email                        | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com                    | 2017-12-31 | 2018-12-31  | member_fee   | betald | none    | 2120000142     |
      | emma@mutts.com                    | 2017-12-31 | 2018-12-31  | branding_fee | betald | none    | 2120000142     |
      | bob-former-member@snarkybarky.com | 2018-03-01 | 2019-02-28  | member_fee   | betald | none    | 5560360793     |
      | bob-former-member@snarkybarky.com | 2018-03-02 | 2019-03-01  | branding_fee | betald | none    | 5560360793     |

    Given these files have been uploaded:
      | user_email     | file name | description                               |
      | emma@mutts.com | image.png | Image of a class completion certification |



  # TODO should these be put into already existing .feature files?

  # --- MEMBERSHIP PAYMENTS -------------

  @time_adjust
  Scenario: Membership payment made before membership expires (but not too early)
    Given the date is set to "2018-11-30"
    And I am logged in as "emma@mutts.com"
    When I am on the "user details" page for "emma@mutts.com"
    Then I should see "1001"
    When I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And my membership expiration date should be 2019-12-31
    And I should see "2019-12-31"


  @time_adjust
  Scenario: Membership payment made 1 day after membership expires
    Given the date is set to "2019-01-01"
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I am not a member
    When I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And I should be a current member
    And I should see "2019-12-31"


    #TODO should this be ...is made on the last day ?
  @time_adjust
  Scenario: Membership payment is made on expiration date
    Given the date is set to "2018-12-31"
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I am not a member
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And I should see "2019-12-31"
    And I should be a member
    And my membership expiration date should be 2019-12-31


  @time_adjust
  Scenario: Membership payment within grace period to renew after expiration
    Given the date is set to "2019-01-01"
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I am in the grace period
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And I should see "2019-12-31"
    And I should be a member
    And my membership expiration date should be 2019-12-31


  @time_adjust
  Scenario: Membership payment after grace period (after expiration)
    Given the date is set to "2021-01-01"
    And I am logged in as "bob-former-member@snarkybarky.com"
    And I am on the "user details" page for "bob-former-member@snarkybarky.com"
    And I am not a member
    When I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And I should be a member
    And my membership expiration date should be 2021-12-31
    And I should see "2021-12-31"


  # H-BRANDING (LICENSE) PAYMENT


  # H-branding expires for a company



  # APPLICATION STATE


  # CODE OF CONDUCT (TBD)

