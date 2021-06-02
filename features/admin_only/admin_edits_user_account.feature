Feature: Admin edits a user account

  As an admin
  I need to be able to edit all of the user's account information.

  Background:

    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the date is set to "2020-11-01"

    Given the following users exist
      | email                               | password       | admin | membership_status |member | first_name | last_name | membership_number |
      | admin@shf.se                        | admin_password | true  |                   |false  | emma       | admin     |                   |
      | member@shf.com                      | password       | false | current_member    |true   | mary       | member    | 9                 |
      | applicant@example.com               | password       | false |                   |false  | Alf        | Applicant |                   |
      | applicant-with-old-pays@example.com | password       | false |                   |false  | OldPays    | Applicant |                   |
      | user@example.com                    | password       | false |                   |false  | Ursa       | User      |                   |
      | user-with-old-pays@example.com      | password       | false |                   | false  | OldPays    | User      |                   |


    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |

    And the following applications exist:
      | user_email                          | company_number | categories   | state    |
      | member@shf.com                      | 5562252998     | dog grooming | accepted |
      | applicant@example.com               | 5562252998     | dog grooming | new      |
      | applicant-with-old-pays@example.com | 5562252998     | dog grooming | new      |


    And the following payments exist
      | user_email                          | start_date | expire_date | payment_type | status | hips_id |
      | applicant-with-old-pays@example.com | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |
      | user-with-old-pays@example.com      | 2018-10-31 | 2019-10-30  | member_fee   | betald | none    |
      | member@shf.com                      | 2020-09-01 | 2021-08-30  | member_fee   | betald | none    |

    And the following memberships exist:
      | email | first_day | last_day |
      |member@shf.com | 2020-09-01 | 2021-08-30 |

    Given I am logged in as "admin@shf.se"

    # ---------------------------------------------------------------------------------------------

  @selenium
  Scenario: Admin edits membership number
    Given I am on the "edit user account" page for "member@shf.com"
    Then I should see "member@shf.com"
    And the t("activerecord.attributes.user.membership_number") field should be set to "9"
    And I fill in t("activerecord.attributes.user.membership_number") with "1010101"
    When I click on t("submit") button
    Then I should see t("admin_only.user_account.update.success")
    And I should see "mary Member"
    And I should see "1010101"


  @selenium
  Scenario: Admin sees button to change member status for a member
    Given I am on the "user account" page for "member@shf.com"
    Then I should see t("users.show.is_a_member")
    And I should see t("users.show.edit_member_status")


  @selenium
  Scenario: Admin sees button to change member status for an applicant that has past payments
    Given I am on the "user account" page for "applicant-with-old-pays@example.com"
    Then I should not see t("users.show.is_a_member")
    And I should see t("users.show_for_applicant.app_status_new")
    And I should see t("users.show.edit_member_status")


  @selenium
  Scenario: Admin does not see button to change member status for an applicant that has no past payments
    Given I am on the "user account" page for "applicant@example.com"
    Then I should not see t("users.show.is_a_member")
    And I should see t("users.show_for_applicant.app_status_new")
    And I should not see t("users.show.edit_member_status")
    And I should see t("payors.admin_cant_edit")


  @selenium
  Scenario: Admin sees button to change member status for a user with past payments
    Given I am on the "user account" page for "user-with-old-pays@example.com"
    Then I should not see t("users.show.is_a_member")
    And I should not see t("users.show_for_applicant.app_status_new")
    And I should see t("users.show.edit_member_status")


  @selenium
  Scenario: Admin does not see button to change member status for a user with no past payments
    Given I am on the "user account" page for "user@example.com"
    Then I should not see t("users.show.is_a_member")
    And I should not see t("users.show_for_applicant.app_status_new")
    And I should not see t("users.show.edit_member_status")
    And I should see t("payors.admin_cant_edit")
