Feature: As a registered user
  I want to be able to edit my profile
  Including my first name, last name, email and password

  Background:
    Given the following users exists
      | email             | password | admin | member    | first_name | last_name |
      | admin@random.com  | password | true  | false     | emma       | admin     |
      | member@random.com | password | false | true      | mary       | member    |
      | newmember@me.com  | password | false | true      | newest     | member    |
      | user@random.com   | password | false | false     | ulysses    | user      |

    And the following applications exist:
      | user_email        | company_number | state    | contact_email     | is_legacy |
      | member@random.com | 5560360793     | accepted | public@random.com | true      |
      | newmember@me.com  | 9999999999     | accepted | public@random.com |           |

    And the following payments exist
      | user_email        | start_date | expire_date | payment_type | status | hips_id |
      | member@random.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | newmember@me.com  | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |

  Scenario: Admin edits profile
    Given I am logged in as "admin@random.com"
    And I am on the "landing" page
    And I should see t("hello", name: 'emma')
    Then I click on the t("devise.registrations.edit.title") link
    And I fill in t("activerecord.attributes.user.first_name") with "NewEmma"
    And I fill in t("activerecord.attributes.user.last_name") with "NewAdmin"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("hello", name: 'NewEmma')
    Then I click on the t("devise.registrations.edit.title") link
    And the t("activerecord.attributes.user.last_name") field should be set to "NewAdmin"
    And I fill in t("activerecord.attributes.user.password") with "NewPassword"
    And I fill in t("devise.registrations.edit.confirm_password") with "password"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("activerecord.errors.models.user.attributes.password_confirmation.confirmation")
    Then I fill in t("activerecord.attributes.user.password") with "NewPassword"
    And I fill in t("devise.registrations.edit.confirm_password") with "NewPassword"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    Then I should see t("devise.registrations.edit.success")

  @time_adjust
  Scenario: "Legacy" member edits profile, uploads photo, returns to prior page after update
    Given the date is set to "2017-10-01"
    And I am logged in as "member@random.com"
    And I am on the "show my application" page
    And I should see t("hello", name: 'mary')
    Then I click on the t("devise.registrations.edit.title") link
    And I fill in t("activerecord.attributes.user.first_name") with "NewMary"
    And I choose a "user_member_photo" file named "member_with_dog.png" to upload
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("hello", name: 'NewMary')
    And I should be on "show my application" page
    Then I click on the t("devise.registrations.edit.title") link
    And I should see "member_with_dog.png"

  @time_adjust
  Scenario: Member edits profile
    Given the date is set to "2019-01-02"
    And I am logged in as "newmember@me.com"
    And I am on the "show my application" page
    And I should see t("hello", name: 'newest')
    Then I click on the t("devise.registrations.edit.title") link
    And I fill in t("activerecord.attributes.user.first_name") with "Henry"
    And I choose a "user_member_photo" file named "member_with_dog.png" to upload
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("hello", name: 'Henry')
    And I should be on "show my application" page
    Then I click on the t("devise.registrations.edit.title") link
    And I should see "member_with_dog.png"

  @time_adjust
  Scenario: Member edits profile and tries to upload non-image file (for photo)
    Given the date is set to "2017-10-01"
    And I am logged in as "member@random.com"
    And I am on the "landing" page
    And I should see t("hello", name: 'mary')
    Then I click on the t("devise.registrations.edit.title") link
    And I choose a "user_member_photo" file named "text_file.jpg" to upload
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("activerecord.errors.models.user.attributes.member_photo.spoofed_media_type")

  Scenario: User edits profile
    Given I am on the "landing" page
    When I click on t("devise.sessions.new.log_in") link
    Then I should be on "login" page
    And I fill in t("activerecord.attributes.user.email") with "user@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    And I should see t("hello", name: 'ulysses')
    Then I click on the t("devise.registrations.edit.title") link
    And I fill in t("activerecord.attributes.user.first_name") with "NewUlysses"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("hello", name: 'NewUlysses')

  Scenario: Member edits contact email in profile
    Given I am logged in as "member@random.com"
    And I am on the "landing" page
    Then I click on the t("devise.registrations.edit.title") link
    And I fill in t("activerecord.attributes.shf_application.contact_email") with "changed@random.com"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    Then I click on the t("devise.registrations.edit.title") link
    And the t("activerecord.attributes.shf_application.contact_email") field should be set to "changed@random.com"
