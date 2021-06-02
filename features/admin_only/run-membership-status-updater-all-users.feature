Feature: Update the membership status for all users

  As an admin
  So I can verify that the membership status is updated correctly
  When changes are made to user information,
  I need to be able to update the membership status for all users

  Background:
#    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | email         | password | admin | membership_status | member | first_name | last_name     | membership_number |
      | admin@shf.se  | password | true  |                   |        | Admin      | Administrator |                   |
      | member@shf.se | password | false | current_member    | true   | Mary       | Member        | 1001              |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 5562252998     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email    | company_number | categories | state    |
      | member@shf.se | 5562252998     | rehab      | accepted |


    Given the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member@shf.se | 2019-1-1   | 2019-12-31  | member_fee   | betald | none    |                |
      | member@shf.se | 2019-1-1   | 2019-12-31  | branding_fee | betald | none    | 5562252998     |


    And the following memberships exist
      | email         | first_day | last_day   | notes |
      | member@shf.se | 2019-1-1  | 2019-12-31 |       |


    Given I am logged in as "admin@shf.se"
    And I am on the "business categories" page
    # It doesn't matter what page the admin is on.  But this one does a smaller query that others.

  # ---------------------------------------------------------------------------------------------

  Scenario: Admin sees modal and confirms they do  want to update all Users, sees success message and is taken to All Users page
    When I click on t("hello", name: "Admin")
    And I click on t("menus.nav.admin.update_all_membership_status")
    Then I should see t("admin_only.user_account.update_membership_status_all_modal.title")
    When I click on t("admin_only.user_account.update_membership_status_all_modal.confirm_do_updates")
    And I should be on the "all users" page
    And I should see t("admin_only.user_account.update_membership_status_all.success")


  @selenium
  Scenario: Admin sees modal and dimisses modal (they do not want to update all Users)
    Given I am logged in as "admin@shf.se"
    And I am on the landing page
    When I click on t("hello", name: "Admin")
    And I click on t("menus.nav.admin.update_all_membership_status")
    Then I should see t("admin_only.user_account.update_membership_status_all_modal.title")
    When I click on t("close")
    And I should not see t("admin_only.user_account.update_membership_status_all.success")
    And I should not see t("admin_only.user_account.update_membership_status_all.error")


