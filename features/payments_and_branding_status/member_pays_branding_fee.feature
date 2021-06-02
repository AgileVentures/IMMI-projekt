Feature: Member pays branding license fee for a company

  As a member
  So that my company can use or maintain H-branding license rights
  I need to be able to pay the branding fee


  Background:

    Given the date is set to "2018-01-01"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                               | admin | membership_status | member | membership_number | first_name |
      | emma@mutts.com                      |       | current_member    | true   | 1001              | Emma       |
      | lars-member@co-with-no-payments.com | false | current_member    | true   | 1002              | Lars       |
      | admin@shf.se                        | true  |                   | false  |                   | Admin      |

    Given the following companies exist:
      | name                     | company_number | email                         | region    |
      | HappyMutts               | 2120000142     | woof@happymutts.com           | Stockholm |
      | NewCompanyWithNoPayments | 5560360793     | hello@co-with-no-payments.com | Stockholm |

    Given the following applications exist:
      | user_email                          | company_number | category_name | state    |
      | emma@mutts.com                      | 2120000142     | rehab         | accepted |
      | lars-member@co-with-no-payments.com | 5560360793     | rehab         | accepted |


    # Emma has (magically) paid her membership fee until 2019-12-31, but the company branding-fee only through 2018-12-31
    Given the following payments exist
      | user_email                          | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com                      | 2018-01-01 | 2019-12-31  | member_fee   | betald | none    |
      | lars-member@co-with-no-payments.com | 2018-01-01 | 2018-12-31  | member_fee   | betald | none    |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 2120000142     |


    And the following memberships exist:
      | email                               | first_day  | last_day   |
      | emma@mutts.com                      | 2018-01-01 | 2019-12-31 |
      | lars-member@co-with-no-payments.com | 2018-01-01 | 2018-12-31 |

  # -------------------------------------------------------------------------------------------

  @time_adjust @selenium
  Scenario: Member pays the first branding fee for a company
    Given the date is set to "2018-12-30"
    And I am logged in as "lars-member@co-with-no-payments.com"
    And I am the page for company number "5560360793"
    Then I should see "NewCompanyWithNoPayments"
    And I should see t("payors.due")
    When I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "NewCompanyWithNoPayments"
    Then I should see t("payments.success.success")
    And company number "5560360793" is paid through "2019-12-29"


  @time_adjust @selenium
  Scenario: Member pays branding fee and extends license period
    Given the date is set to "2018-12-30"
    And I am logged in as "emma@mutts.com"
    And I am the page for company number "2120000142"
    Then I should see "HappyMutts"
    And I should see t("payors.due_by", due_date: '2018-12-31')
    When I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "HappyMutts"
    Then I should see t("payments.success.success")
    And company number "2120000142" is paid through "2019-12-31"


  @time_adjust @selenium
  Scenario: Member pays branding fee 'too soon' (way early) before the term has expired
    Given the date is set to "2018-01-02"
    And I am logged in as "emma@mutts.com"
    And I am the page for company number "2120000142"
    Then I should see "HappyMutts"
    And I should see t("payors.too_early")
    When I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "HappyMutts"
    Then I should see t("payments.success.success")
    And company number "2120000142" is paid through "2019-12-31"


  @time_adjust @selenium
  Scenario: Member pays branding fee after the term has expired
    Given the date is set to "2019-02-02"
    And I am logged in as "emma@mutts.com"
    And I am the page for company number "2120000142"
    Then I should see "HappyMutts"
    And I should see t("payors.past_due")
    When I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "HappyMutts"
    Then I should see t("payments.success.success")
    And company number "2120000142" is paid through "2020-02-01"


    # Note that you must go to the page _after_ the date has been set for this example so that the browser (via cucumber and Timecop) thinks the date it 2018-12-31.
    # Without the 'I am the page for company number "2120000142"' step explicitly in the scenario below, the date will 'be' "2018-01-01"
    # and it will be too early for a payment to be made, and a modal dialog box will come up with that info.
  @selenium @time_adjust
  Scenario: Member starts payment process then abandons it
    Given the date is set to "2018-12-30"
    And I am logged in as "emma@mutts.com"
    And I am the page for company number "2120000142"
    When I click on t("menus.nav.company.pay_branding_fee")
    And I abandon the payment by going back to the previous page
    Then I should not see t("payments.success.success")
    And company number "2120000142" is paid through "2018-12-31"

  @time_adjust @selenium
  Scenario: Member incurs error in payment processing
    Given the date is set to "2018-12-30"
    And I am logged in as "emma@mutts.com"
    And I am the page for company number "2120000142"
    Then company number "2120000142" is paid through "2018-12-31"
    And I incur an error in branding payment processing for "HappyMutts"
    Then I should see t("payments.error.error")
    And company number "2120000142" is paid through "2018-12-31"
