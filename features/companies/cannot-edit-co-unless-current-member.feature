Feature: A user can edit their company only if they are a current member

  As a user
  So that only those that we know are following all the guidelines and requirements for membership
  and whose membership has not ended in the past (even if they are in the renewal 'grace period'),
  Only current members can edit company information.

  Background:
    Given the App Configuration is not mocked and is seeded
    And the grace period is 4 days

    And the Membership Ethical Guidelines Master Checklist exists

    Given the date is set to "2018-01-01"

    Given the following users exist:
      | email          | admin | membership_status | member | membership_number | agreed_to_membership_guidelines |
      | emma@mutts.com |       | current_member    | true   | 1001              | true                            |
      | admin@shf.se   | true  |                   | false  |                   |                                 |


    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | state    |
      | emma@mutts.com | 2120000142     | accepted |


    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | emma@mutts.com | 2018-01-1  | 2018-12-31  | branding_fee | betald | none    | 2120000142     |


    Given these files have been uploaded:
      | user_email     | file name | description                               |
      | emma@mutts.com | image.png | Image of a class completion certification |

    Given the following memberships exist:
      | email          | first_day | last_day   |
      | emma@mutts.com | 2018-01-1 | 2018-12-31 |

  # -----------------------------------------------------------------------------------------------

  @time_adjust
  Scenario: Member can no longer edit company once membership has expired
    Given the date is set to "2018-10-01"
    And I am logged in as "emma@mutts.com"
    When I am on the page for company number "2120000142"
    Then I should see t("companies.edit_company")
    And I should see t("companies.show.add_address")

    Given I am logged out
    And the date is set to "2019-01-01"
    And I am logged in as "emma@mutts.com"
    And I am not a current member
    When I am on the page for company number "2120000142"
    Then I should not see t("companies.edit_company")
    And I should not see t("companies.show.add_address")

