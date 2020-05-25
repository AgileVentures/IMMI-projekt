Feature: Applicant home (account) page - version 1.0

  As a user that has applied or will apply,
  my account page needs provide me with the clear ways to complete each step needed for membership:
  1. fill out my application,
  2. agree to the ethical guidelines,
  3. pay my membership fee.


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists
    And the application file upload options exist

    # Default is that the Ethical guidelines are required.
    # Some scenarios below test for when they are NOT required.
    And the date is set to "2020-03-01"
    And the start date for the Membership Ethical Guidelines is 2020-01-01

    And the following users exist:
      | email                              | password | admin | member | first_name               | last_name |
      | admin@shf.se                       | password | true  | false  | emma                     | admin     |
      | registered-only@random.com         | password | false | false  | RegisteredOnly           | user      |
      | submitted-app@random.com           | password | false | false  | SubmittedApp             | user      |
      | applied-many-companies@example.com | password | false | false  | AppWithManyCompanies     | user      |
      | being-reviewed-app@random.com      | password | false | false  | BeingReviewedApp         | user      |
      | waiting-for-info-app@random.com    | password | false | false  | WaitingForUserApp        | user      |
      | ready-for-review-app@random.com    | password | false | false  | ReadyForReviewAgainApp   | user      |
      | accepted-app@random.com            | password | false | false  | AcceptedApp              | user      |
      | rejected-app@random.com            | password | false | false  | RejectedApp              | user      |
      | partial-guidelines@random.com      | password | false | false  | PartialGuidelines        | user      |
      | guidelines-done@random.com         | password | false | false  | GuidelinesDone           | user      |
      | app-guidelines@random.com          | password | false | false  | AppAndGuidelinesDone     | user      |
      | app-guidelines-payment@random.com  | password | false | false  | AppGuidelinesPaymentDone | user      |


    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    And the following companies exist:
      | name                 | company_number | email                | region    |
      | Bowsers              | 5560360793     | woof@bowsers.com     | Stockholm |
      | No More Snarky Barky | 2120000142     | bark@snarkybarky.com | Stockholm |


    And the following applications exist:
      | user_email                         | company_number | state                 | contact_email                      |
      | submitted-app@random.com           | 5560360793     | new                   | submitted-app@random.com           |
      | applied-many-companies@example.com | 5560360793     | new                   | applied-many-companies@example.com |
      | applied-many-companies@example.com | 2120000142     | new                   | applied-many-companies@example.com |
      | being-reviewed-app@random.com      | 5560360793     | under_review          | being-reviewed-app@random.com      |
      | waiting-for-info-app@random.com    | 5560360793     | waiting_for_applicant | public@random.com                  |
      | ready-for-review-app@random.com    | 5560360793     | ready_for_review      | public@random.com                  |
      | accepted-app@random.com            | 5560360793     | accepted              | public@random.com                  |
      | rejected-app@random.com            | 5560360793     | rejected              | public@random.com                  |
      | app-guidelines@random.com          | 5560360793     | accepted              | public@random.com                  |
      | app-guidelines-payment@random.com  | 5560360793     | accepted              | public@random.com                  |

    And the following payments exist
      | user_email                        | start_date | expire_date | payment_type | status | hips_id |
      | app-guidelines-payment@random.com | 2020-02-02 | 2021-02-01  | member_fee   | betald | none    |


  Scenario: After logging in, a newly registered user is taken to their account page
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "registered-only@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: Agreement to Ethical Guidelines not required yet; no guidelines link is shown
    Given I am on the "login" page
    And the start date for the Membership Ethical Guidelines is 2021-06-06
    When I fill in t("activerecord.attributes.user.email") with "registered-only@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should see t("users.show_for_applicant.apply_4_membership") link
    And I should not see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: App has been submitted (not reviewed yet)
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "submitted-app@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should not see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.show_for_applicant.app_status_new")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: App has been accepted
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "accepted-app@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should not see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.show_for_applicant.app_status_accepted")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: App accepted; agreement to ethical guidelines not required yet
    Given I am on the "login" page
    And the start date for the Membership Ethical Guidelines is 2021-06-06
    When I fill in t("activerecord.attributes.user.email") with "accepted-app@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should not see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.show_for_applicant.app_status_accepted")
    And I should not see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should not be disabled


  Scenario: App has been rejected
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "rejected-app@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should not see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.show_for_applicant.app_status_rejected")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: App is being reviewed
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "being-reviewed-app@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should not see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.show_for_applicant.app_status_under_review")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: App is waiting for more info from applicant
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "waiting-for-info-app@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should not see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.show_for_applicant.app_status_waiting_for_applicant")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: App is ready for review (again)
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "ready-for-review-app@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should not see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.show_for_applicant.app_status_ready_for_review")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: Ethical Guidelines partially accepted, not submitted app yet
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "partial-guidelines@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: Ethical guidelines finished
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "guidelines-done@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should see t("users.show_for_applicant.apply_4_membership") link
    And I should see t("users.ethical_guidelines_link_or_checklist.agreed_to")
    And the link button t("users.show.pay_membership") should be disabled


  Scenario: App submitted and accepted and ethical guidelines finished
    Given I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "app-guidelines@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And I should see t("users.show_for_applicant.app_status_accepted")
    And I should see t("users.ethical_guidelines_link_or_checklist.agreed_to")
    And I should see t("users.show.pay_membership") link



  # ======================
  # Application Information


  Scenario: User has applied, shows email, status (new), company number and company name
    Given I am logged in as "submitted-app@random.com"
    When I am on the "user account" page for "submitted-app@random.com"
    Then I should see t("application")
    And I should see t("activerecord.attributes.shf_application.contact_email")
    And I should see t("activerecord.attributes.shf_application.state")
    And I should see t("shf_applications.shf_application_min_info_as_table.org_nr")
    And I should see t("shf_applications.shf_application_min_info_as_table.company_name")
    And I should see "submitted-app@random.com" in the minimal shf application info row
    And I should see t("shf_applications.state.new") in the minimal shf application info row
    And I should see "Bowsers" in the minimal shf application info row
    And I should see "5560360793" in the minimal shf application info row


  Scenario: Application has more than 1 company; every company name and number is shown
    Given I am logged in as "applied-many-companies@example.com"
    When I am on the "user account" page for "applied-many-companies@example.com"
    Then I should see t("application")
    And I should see "Bowsers"
    And I should see "5560360793"
    And I should see "No More Snarky Barky"
    And I should see "2120000142"
