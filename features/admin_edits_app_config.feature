Feature: Admin edits application configuration
  As an admin
  I want to be able to edit application configuration
  Including chair signature and SHG logo images

  Background:
    Given the following users exists
      | email             | password | admin |
      | admin@random.com  | password | true  |

  Scenario: Admin uploads SHF logo and chairperson signature
    Given I am logged in as "admin@random.com"
    And I am on the "landing" page
    Then I click on the t("menus.nav.admin.app_configuration") link
    And I should see t("admin_only.app_configuration.edit.title")
    And I choose an SHF "admin_only_app_configuration[chair_signature]" file named "chair_signature.png" to upload
    And I choose an SHF "admin_only_app_configuration[shf_logo]" file named "medlem.png" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")

  Scenario: Admin edits app configuration and tries to upload non-image file
    Given I am logged in as "admin@random.com"
    And I am on the "landing" page
    Then I click on the t("menus.nav.admin.app_configuration") link
    And I should see t("admin_only.app_configuration.edit.title")
    And I choose an SHF "admin_only_app_configuration[shf_logo]" file named "text_file.jpg" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.error")
