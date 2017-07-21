Feature: As a visitor
  in order to access the functions of the site
  I need to be able to create an account

  Scenario: Creating an account
    Given I am on the "login" page
    And I click on t("devise.registrations.new.create_account")
    Then I should be on the "register as a new user" page
    When I fill in t("activerecord.attributes.user.first_name") with "emma"
    And I fill in t("activerecord.attributes.user.last_name") with "andersson"
    And I fill in t("activerecord.attributes.user.email") with "emma@andersson.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I fill in t("devise.registrations.new.confirm_password") with "password"
    And I click on t("devise.registrations.new.submit_button_label")
    Then I should see t("devise.registrations.new.success")
    When I am on the "edit registration for a user" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "emma"
    And the t("activerecord.attributes.user.last_name") field should be set to "andersson"

  Scenario: Sad path: Missing first name
    Given I am on the "register as a new user" page
    And I fill in t("activerecord.attributes.user.last_name") with "andersson"
    And I fill in t("activerecord.attributes.user.email") with "emma@andersson.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I fill in t("devise.registrations.new.confirm_password") with "password"
    And I click on t("devise.registrations.new.submit_button_label")
    Then I should see translated error activerecord.attributes.user.first_name errors.messages.blank
    And I should not see t("devise.registrations.new.success")
    When I am on the "edit registration for a user" page
    Then I should be on the "login" page

  Scenario: Sad path: Missing last name
    Given I am on the "register as a new user" page
    And I fill in t("activerecord.attributes.user.first_name") with "emma"
    And I fill in t("activerecord.attributes.user.email") with "emma@andersson.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I fill in t("devise.registrations.new.confirm_password") with "password"
    And I click on t("devise.registrations.new.submit_button_label")
    Then I should see translated error activerecord.attributes.user.last_name errors.messages.blank
    And I should not see t("devise.registrations.new.success")
    When I am on the "edit registration for a user" page
    Then I should be on the "login" page
