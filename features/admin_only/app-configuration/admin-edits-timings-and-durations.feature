Feature: Admin edits membership durations and timings in App Configuration

  As an admin
  So that I can control when users and members see warning and get alerts,
  I need to be able to adjust the timing of them.

  As an admin
  So that I can adjust the grace period and membership term durations
  to be what the SHF board has decided
  I need to be able to view and edit them.


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists
    And the App Configuration is not mocked and is seeded

    Given the following users exist:
      | email        | password | admin | member | first_name | last_name |
      | admin@shf.se | password | true  | false  | emma       | admin     |


    And the membership term is 1 year, 2 months, and 3 days
    And the grace period is 4 years, 5 months, and 6 days

    And the payment window is 33 days
    And the term ending warning window is 22 days

    And I am logged in as "admin@shf.se"

  # ===============================================================================================


  Example: Admin sees words that describe the durations (membership term, grace period)
    Given I am on the "admin app configuration" page
    Then I should see t("admin_only.app_configuration.show.durations.membership_term_duration")
    And I should see a duration of 1 year, 2 months, and 3 days
    And I should see t("admin_only.app_configuration.show.durations.membership_term_duration")
    And I should see a duration of 4 years, 5 months, and 6 days


  Example: Admin sees timings: number of days before due day that payment can be made, term expiring soon and their descriptions
    Given I am on the "admin app configuration" page
    And I should see the number of days that it is too early to pay is 33
    And I should see t("admin_only.app_configuration.show.payment_too_soon_days")
    And I should see the number of days to warn that the term is ending is 22
    And I should see t("admin_only.app_configuration.show.membership_expiring_soon_days")


  Example: Admin edits membership term duration
    Given I am on the "admin edit app configuration" page
    And I fill in "membership_term_duration_years" with "99"
    And I fill in "membership_term_duration_months" with "88"
    And I fill in "membership_term_duration_days" with "77"
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")
    And I should see t("admin_only.app_configuration.show.title") in the h1 title
    And I should see a duration of 99 years, 88 months, and 77 days


  Example: Admin edits grace period duration
    Given I am on the "admin edit app configuration" page
    And I fill in "membership_expired_grace_period_duration_years" with "11"
    And I fill in "membership_expired_grace_period_duration_months" with "22"
    And I fill in "membership_expired_grace_period_duration_days" with "33"
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")
    And I should see t("admin_only.app_configuration.show.title") in the h1 title
    And I should see a duration of 11 years, 22 months, and 33 days


  Example: Admin edits payment window
    Given I am on the "admin edit app configuration" page
    And I fill in "admin_only_app_configuration_payment_too_soon_days" with "24"
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")
    And I should see t("admin_only.app_configuration.show.title") in the h1 title
    And I should see the number of days that it is too early to pay is 24


  Example: Admin edits term ends soon window
    Given I am on the "admin edit app configuration" page
    And I fill in "admin_only_app_configuration_membership_expiring_soon_days" with "42"
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")
    And I should see t("admin_only.app_configuration.show.title") in the h1 title
    And I should see the number of days to warn that the term is ending is 42
