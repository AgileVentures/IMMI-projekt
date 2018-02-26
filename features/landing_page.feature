Feature: As a Member
  So that I can get the correct information
  Information page should show correct information

  Background:
    Given the following users exist
      | email           | admin | member | membership_number |
      | anna@muffs.com  |       | false  |                   |
      | fanny@mutts.com |       | true   | 1002              |
      | emma@mutts.com  |       | true   | 1001              |
      | new@mutts.com   |       | false  |                   |
      | admin@shf.se    | true  | false  |                   |

    Given the following companies exist:
      | name       | company_number | email                 | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com   | Stockholm |
      | HappyMuffs | 6222279082     | woof@happymuffs.com   | Stockholm |

    Given the following applications exist:
      | user_email      | company_number | category_name | state         |
      | emma@mutts.com  | 2120000142     | rehab         | accepted      |
      | anna@muffs.com  | 6222279082     | other         | under_review  |
      | fanny@mutts.com | 6222279082     | other         | accepted  |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2017-10-1  | 2018-01-31  | branding_fee | betald | none    | 2120000142     |
      | emma@mutts.com | 2017-10-1  | 2018-02-27  | member_fee   | betald | none    |                |

  Scenario: After login, Admin still sees new memberships on their landing page
    Given I am logged in as "admin@shf.se"
    When I am on the "landing" page
    Then I should see t("shf_applications.index.title")

  @selenium @time_adjust
  Scenario: After login, Member sees correct instructions
    Given the date is set to "2017-01-01"
    And I am logged in as "emma@mutts.com"
    When I am on the "user instructions" page
    Then I should not see t("shf_applications.index.title")
    And I should see t("shf_applications.information.member.using_the_h_mark")
    And I should not see t("menus.nav.users.apply_for_membership")
    And I should not see t("shf_applications.information.waiting_for_approval.in_process")

  Scenario: After login, User sees how to apply etc
    Given I am logged in as "new@mutts.com"
    When I am on the "user instructions" page
    Then I should not see t("info.logged_in_as_admin")
    And I should not see t("shf_applications.information.member.using_the_h_mark")
    And I should not see t("shf_applications.information.waiting_for_approval.in_process")
    And I should see t("menus.nav.users.apply_for_membership")

  Scenario: Visitor does not see instructions
    Given I am Logged out
    When I am on the "user instructions" page
    Then I should not see t("info.logged_in_as_admin")
    And I should not see t("shf_applications.information.member.using_the_h_mark")
    And I should not see t("shf_applications.information.waiting_for_approval.in_process")
    And I should not see t("menus.nav.users.apply_for_membership")

  @selenium @time_adjust
  Scenario: After login, Member sees correct instructions about member fee
    Given the date is set to "2018-03-01"
    And I am logged in as "emma@mutts.com"
    When I am on the "user instructions" page
    Then I should see t("shf_applications.information.check_payment_status.m_expires")
    When I click on t("menus.nav.members.pay_membership")
    Then I should be on the "user details" page for "emma@mutts.com"

  @selenium @time_adjust
  Scenario: After login, Member sees correct instructions about H branding
    Given the date is set to "2018-02-01"
    And I am logged in as "emma@mutts.com"
    When I am on the "user instructions" page
    Then I should see t("shf_applications.information.check_payment_status.h_expires")
    And I should not see t("shf_applications.information.check_payment_status.m_expires")
    And I should not see t("shf_applications.information.waiting_for_approval.in_process")
    When I click on t("menus.nav.company.pay_branding_fee")
    Then I should be on the "my company" page for "emma@mutts.com"

  Scenario: After login, user with accepted app but with no membership payment sees instructions to pay
    And I am logged in as "fanny@mutts.com"
    When I am on the "user instructions" page
    Then I should see t("shf_applications.information.check_payment_status.pay_m_here")
    And I should not see t("shf_applications.information.check_payment_status.m_expires")
    And I should not see t("shf_applications.information.waiting_for_approval.in_process")
    When I click on t("menus.nav.members.pay_membership")
    Then I should be on the "user details" page for "fanny@mutts.com"

  Scenario: After login, Member without previously paid H-branding sees correct instructions about H branding
    And I am logged in as "fanny@mutts.com"
    When I am on the "user instructions" page
    Then I should see t("shf_applications.information.check_payment_status.pay_h_here")
    And I should not see t("shf_applications.information.check_payment_status.h_expires")
    And I should not see t("shf_applications.information.waiting_for_approval.in_process")
    When I click on t("menus.nav.company.pay_branding_fee")
    Then I should be on the "my company" page for "fanny@mutts.com"

  Scenario: After login, user with accepted app sees info about their app being handled
    Given I am logged in as "anna@muffs.com"
    When I am on the "user instructions" page
    Then I should see t("shf_applications.information.waiting_for_approval.in_process")
    And I should not see t("shf_applications.information.check_payment_status.m_expires")