Feature: Admin enables/disables the emails sent when a new application is received

  As an admin
  I want to be able to turn off (disable) emails that are sent out to the admin when a new application is received
  And I want to be able to turn them on (enable) them so they are sent.


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                 | admin | member |
      | new_user1@example.com |       |        |
      | admin@shf.se          | true  |        |

    And the following business categories exist
      | name    |
      | Groomer |

    And the application file upload options exist

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |

    And the App Configuration is not mocked and is seeded


  @selenium
  Scenario: Admin disables send new app received emails
    Given I am logged in as "admin@shf.se"
    When I am on the "admin edit app configuration" page
    Then I should see t("admin_only.app_configuration.show.title")
    And I should see the checkbox with id "admin_only_app_configuration_email_admin_new_app_received_enabled" checked
    And I uncheck the checkbox with id "admin_only_app_configuration_email_admin_new_app_received_enabled"
    And I click on t("submit")
    And I am logged out

    Given I am logged in as "new_user1@example.com"
    And I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                          | 031-1234567                       | new_user1@example.com               |
    And I check the checkbox with id "shf_application_business_category_ids_1"

    And I select files delivery radio button "upload_now"

    When I click on t("shf_applications.new.submit_button_label")

    Then I should see t("shf_applications.create.success_with_app_files_missing")

    Given I am logged out
    When I am logged in as "admin@shf.se"
    Then "admin@shf.se" should receive 0 email

  @selenium
  Scenario: Admin enables send new app received emails
    Given I am logged in as "admin@shf.se"
    And I am on the "admin edit app configuration" page
    And I should see t("admin_only.app_configuration.show.title")
    And I should see the checkbox with id "admin_only_app_configuration_email_admin_new_app_received_enabled" checked
    And I uncheck the checkbox with id "admin_only_app_configuration_email_admin_new_app_received_enabled"
    And I check the checkbox with id "admin_only_app_configuration_email_admin_new_app_received_enabled"
    And I click on t("submit")
    And I am logged out

    Given I am logged in as "new_user1@example.com"
    And I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                          | 031-1234567                       | new_user1@example.com               |
    And I check the checkbox with id "shf_application_business_category_ids_1"

    And I select files delivery radio button "upload_now"

    When I click on t("shf_applications.new.submit_button_label")

    Then I should see t("shf_applications.create.success_with_app_files_missing")

    Given I am logged out
    When I am logged in as "admin@shf.se"
    Then "admin@shf.se" should receive 1 email
