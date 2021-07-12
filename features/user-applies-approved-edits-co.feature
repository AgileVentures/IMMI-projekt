Feature: Whole process of a new user creating a login, applying, being approved, editing their company

  This exercises the entire process to ensure that data we are creating in the
  features and/or factories is not somehow masking any problems.

  Background:
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                | admin | first_name | last_name | password       |
      | new_user@example.com |       | NewUser1   | Lastname  | password       |
      | admin@shf.se         | true  |            |           | admin_password |

    And the application file upload options exist

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name     |
      | Alingsås |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |


  @admin, @user, @member, @selenium
  Scenario: User creates application, admin approves, user edits company, blank main address is displayed
    Given I am in "new_user@example.com" browser
    And I am logged in as "new_user@example.com"
    Given I am on the "user account" page for "new_user@example.com"
    When I click on t("users.show_for_applicant.apply_4_membership") link
    And I fill in the translated form with data:
      | shf_applications.new.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                          | 031-1234567                       | new_user@example.com               |
    And I select "Groomer" Category
    And I select files delivery radio button "upload_later"

    And I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success_with_app_files_missing")
    And I should be on the "user account" page for "new_user@example.com"

    And I have agreed to all of the Membership Guidelines

    Then I am in "admin@shf.se" browser
    And I am logged in as "admin@shf.se"
    And I am on the "landing" page
    Then I should see "NewUser1"
    And I am on the "application" page for "new_user@example.com"
    And I click on t("shf_applications.start_review_btn")
    And I click on t("shf_applications.accept_btn")
    And I should be on the "edit application" page for "new_user@example.com"
    And I should not see t("shf_applications.update.enter_member_number")
    And I click on t("shf_applications.edit.submit_button_label")

    And I should see t("shf_applications.update.success_with_app_files_missing")

    And I should see t("shf_applications.accepted")

    Given I am in "new_user@example.com" browser
    And I am logged in as "new_user@example.com"
    And I am on the "user account" page for "new_user@example.com"
    When I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment

    Then I am in "admin@shf.se" browser
    And I am on the "all users" page
    Then I click the icon with CSS class "edit" for the row with "new_user@example.com"
    And I fill in t("activerecord.attributes.user.membership_number") with "10101"
    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    Then I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("admin_only.user_profile.update.success")

    And the t("activerecord.attributes.user.membership_number") field should be set to "10101"

    And I am logged out
    And I am logged in as "new_user@example.com"
#    And I am on the "user details" page for "new_user@example.com"

    And I am on the "edit my company" page

    Then I should see t("companies.edit.title", company_name: "No More Snarky Barky")
    And I should see t("companies.company_name")
    And I should see t("companies.show.company_number")
    And I should see t("companies.telephone_number")
    And I should see t("companies.show.email")
    And I should see t("companies.show.website")

    Then I am on the "my first company" page

    Then I click on t("companies.show.add_address")
    And I should see t("companies.show.street")
    And I should see t("companies.show.post_code")
    And I should see t("companies.show.city")
    And I should see t("companies.show.kommun")
    And I should see t("companies.show.region")
