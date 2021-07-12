Feature: Admin pays branding license fee for a company

  As an admin
  So that I can make payments on behalf on users that cannot do it any other way
  I need to be able to pay the branding license fee for any company


  Background:

    Given the date is set to "2018-01-01"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | email          | admin | member | membership_number | first_name |
      | emma@mutts.com |       | true   | 1001              | Emma       |
      | admin@shf.se   | true  | false  |                   | Admin      |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2018-01-01 | 2018-12-31  | member_fee   | betald | none    |

    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | category_name | state    |
      | emma@mutts.com | 2120000142     | rehab         | accepted |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 2120000142     |


    Given I am logged in as "admin@shf.se"
    Given I am the page for company number "2120000142"


  @time_adjust @selenium
  Scenario: Admin pays branding fee and extends license period
    Given the date is set to "2018-12-31"
    Then I should see "HappyMutts"
    When I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "HappyMutts"
    And company number "2120000142" is paid through "2019-12-30"

    # Note that you must go to the page _after_ the date has been set for this example so that the browser (via cucumber and Timecop) thinks the date it 2018-12-31.
    # Without the 'I am the page for company number "2120000142"' step explicitly in the scenario below, the date will 'be' "2018-01-01" and it will be too early for a payment to be made, and a modal dialog box will come up with that info.
  @selenium @time_adjust
  Scenario: Admin starts payment process then abandons it
    Given the date is set to "2018-12-31"
    And I am the page for company number "2120000142"
    When I click on t("menus.nav.company.pay_branding_fee")
    And I abandon the payment by going back to the previous page
    And I should not see t("payments.confirmation.success_html")
    And company number "2120000142" is paid through "2018-12-31"
