Feature: Former Member home (account) page - version 1.0

  As a former member,
  my account page needs provide me with the clear ways to complete each step needed for membership:
  1. This will show my previous application (because we currently allow only 1 application per user)
  2. I must agree to the ethical guidelines,
  4. any other requirements
  5. pay my membership fee once all other requirements are satisfied


  Background:

    Given the date is set to "2018-01-01"
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                     | admin | membership_status | membership_number | member | first_name | last_name |
      | former-member@example.com |       | former_member      | 1001              | true   | Former     | Member    |
      | admin@shf.se              | true  |                   |                   |        |            |           |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                     |
      | former-member@example.com |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name    | company_number | email            | region    |
      | Bowsers | 2120000142     | bark@bowsers.com | Stockholm |


    And the following business categories exist
      | name     | description   |
      | Grooming | grooming dogs |


    And the following applications exist:
      | user_email                | contact_email             | company_number | state    | categories |
      | former-member@example.com | former-member@bowsers.com | 2120000142     | accepted | Grooming   |


    And the following payments exist
      | user_email                | start_date | expire_date | payment_type | status | hips_id | company_number |
      | former-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | former-member@example.com | 2018-01-1  | 2018-12-31  | branding_fee | betald | none    | 2120000142     |


    And the following memberships exist
      | email                     | first_day | last_day   | notes |
      | former-member@example.com | 2018-01-1 | 2018-12-31 |       |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                     | date agreed to |
      | former-member@example.com | 2017-12-31     |


    Given the date is set to "2021-07-07"

  # ---------------------------------------------------------------------------------------------

  Scenario: Former member sees greeting, name, welcome message, existing application, must agree to guidelines
    Given I am logged in as "former-member@example.com"
    And I am on the "user account" page for "former-member@example.com"
    Then I am not a current member

    And I should see t("users.show.hello")
    And I should see "Former Member"
    And I should see t("users.show_for_applicant.welcome")
    And I should see t("users.show_for_applicant.welcome_want_to_have_benefits")

    And I should not see t("users.show_for_applicant.apply_4_membership") link

    And I should see t("application")
    And I should see t("users.show_for_applicant.app_status_accepted")

    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")

    And the link button t("users.show.pay_membership") should be disabled
