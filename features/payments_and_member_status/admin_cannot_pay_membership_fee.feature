Feature: Admin cannot pay a membership fee for a member

  As an admin
  So that users and members pay the organization directly
  I cannot pay a membership fee for a member


  Background:

    Given the App Configuration is not mocked and is seeded

    Given the date is set to "2017-01-10"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email          | admin | membership_status |member | membership_number |
      | emma@mutts.com |       | current_member    |true   | 1001              |
      | admin@shf.se   | true  |                   |       |                   |

    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | state    |
      | emma@mutts.com | 2120000142     | accepted |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

    And the following memberships exist:
      | email                   | first_day  | last_day   |
      | emma@mutts.com | 2017-01-1  | 2017-12-31 |

  @time_adjust
  Scenario: Admin cannot see the payment button for the member
    Given the date is set to "2018-02-12"
    And I am logged in as "admin@shf.se"
    And I am on the "user details" page for "emma@mutts.com"
    And I should see "1001"
    Then I should not see t("menus.nav.members.pay_membership")

