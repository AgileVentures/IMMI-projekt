Feature: Admins, Members, and Users edit their own User Profile

  As an Admin, Member, or registered User
  in order to be able to change my login email and password,
  and to edit what is displayed to the public
  I need to be able to edit my profile

  Includes editting my first name, last name, email and password and any other info I can edit


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
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


  # -----------------------------------------------
  # ADMIN edits their own profile

  Scenario: Admin edits their own profile
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
    Then I should see t("devise.registrations.updated")


  # -----------------------------------------------
  # MEMBER edits their own profile

  @time_adjust
  Scenario: "Legacy" member edits profile, uploads photo, returns to prior page after update
    Given the date is set to "2017-10-01"
    And I am logged in as "member@random.com"
    And I am on the "show my application" page
    And I should see t("hello", name: 'mary')
#    Then I click on the t("devise.registrations.edit.title") link
    When I am on the "edit my user profile" page
    And I fill in t("activerecord.attributes.user.first_name") with "NewMary"
    And I choose a "user_member_photo" file named "member_with_dog.png" to upload

    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button

    And I should see t("devise.registrations.updated")
    And I should see t("hello", name: 'NewMary')
    And I should be on "show my application" page

    When I click on the t("devise.registrations.edit.title") link

    And I should see "member_with_dog.png"
    Then my profile picture filename is "member_with_dog.png"


  @time_adjust
  Scenario: Member edits profile: edits name and uploads profile picture
    Given the date is set to "2019-01-02"
    And I am logged in as "newmember@me.com"
    And I am on the "edit my user profile" page
    And I fill in t("activerecord.attributes.user.first_name") with "Henry"
    And I choose a "user_member_photo" file named "member_with_dog.png" to upload
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    Then I should be on "edit my user profile" page
    And I should see "Henry"
    And my profile picture filename is "member_with_dog.png"


  @time_adjust
  Scenario: Member edits profile and tries to upload non-image file (for photo)
    Given the date is set to "2017-10-01"
    Given I am logged in as "member@random.com"
    And I am on the "landing" page
    And I should see t("hello", name: 'mary')
    When I am on the "edit my user profile" page
    And I choose a "user_member_photo" file named "text_file.jpg" to upload
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    Then I should see t("activerecord.errors.models.user.attributes.member_photo.spoofed_media_type")


  Scenario: Member edits contact email in profile
    Given I am logged in as "member@random.com"
    And I am on the "landing" page
    Then I click on the t("devise.registrations.edit.title") link
    And I fill in t("activerecord.attributes.shf_application.contact_email") with "changed@random.com"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    Then I click on the t("devise.registrations.edit.title") link
    And the t("activerecord.attributes.shf_application.contact_email") field should be set to "changed@random.com"


  # -----------------------------------------------
  # USER edits their own profile

  Scenario: User edits profile
    Given I am logged in as "user@random.com"
    And I am on the "landing" page
    And I should see t("hello", name: 'ulysses')
    Then I click on the t("devise.registrations.edit.title") link
    And I fill in t("activerecord.attributes.user.first_name") with "NewUlysses"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("hello", name: 'NewUlysses')


  Scenario: Editing User's user profile - change first, last names
    Given I am logged in as "user@random.com"
    And I am on the "edit my user profile" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "ulysses"
    And the t("activerecord.attributes.user.last_name") field should be set to "user"
    And the t("activerecord.attributes.user.email") field should be set to "user@random.com"
    When I fill in t("activerecord.attributes.user.first_name") with "emma (changed)"
    When I fill in t("activerecord.attributes.user.last_name") with "andersson (changed)"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label")
    Then I should see t("devise.registrations.updated")

    When I am on the "edit my user profile" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "emma (changed)"
    And the t("activerecord.attributes.user.last_name") field should be set to "andersson (changed)"


  Scenario: Sad path: changes first name to be empty. No 'success' message; data not changed
    Given I am logged in as "user@random.com"
    And I am on the "edit my user profile" page
    When I fill in t("activerecord.attributes.user.first_name") with ""
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label")
    Then I should see error t("activerecord.attributes.user.first_name") t("errors.messages.blank")
    And I should not see t("devise.registrations.edit.success")
    And I should see t("cannot_change_language") image
    When I am on the "edit registration for a user" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "ulysses"


  Scenario: Sad path: changes last name to be empty. No 'success' message; data not changed
    Given I am logged in as "user@random.com"
    And I am on the "edit my user profile" page
    When I fill in t("activerecord.attributes.user.last_name") with ""
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label")
    Then I should see error t("activerecord.attributes.user.last_name") t("errors.messages.blank")
    And I should not see t("devise.registrations.edit.success")
    And I should see t("cannot_change_language") image
    When I am on the "edit my user profile" page
    Then the t("activerecord.attributes.user.last_name") field should be set to "user"
