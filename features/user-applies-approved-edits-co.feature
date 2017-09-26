Feature: Whole process of a new user creating a login, applying, being approved, editing their company
  This exercises the entire process to ensure that data we are creating in the features and/or factories is not somehow masking any problems.

  Background:
    Given the following users exists
      | email                | admin | is_member |
      | new_user@example.com |       | false     |
      | admin@shf.se         | true  | true      |

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


  @admin, @user, @member
  Scenario: User creates login, admin approves, user edits company, blank main address is displayed
    Given I am logged in as "new_user@example.com"
    And I am on the "landing" page
    And I click on t("menus.nav.users.apply_for_membership")
    And I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | NewUser1                               | NewLastName                           | 5562252998                                 | 031-1234567                              | new_user@example.com                      |
    And I select "Groomer" Category
    And I click on t("membership_applications.new.submit_button_label")
    Then I should be on the "landing" page
    And I should see t("membership_applications.create.success")
    And I am logged out
    And I am logged in as "admin@shf.se"
    And I am on the "landing" page
    And I click on t("menus.nav.admin.manage_applications")
    Then I should see "NewUser1"
    And I am on the "application" page for "new_user@example.com"
    And I click on t("membership_applications.start_review_btn")
    And I click on t("membership_applications.accept_btn")
    And I should be on the "edit application" page for "new_user@example.com"
    And I should see t("membership_applications.update.enter_member_number")
    And I fill in t("membership_applications.show.membership_number") with "10101"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see t("membership_applications.accepted")
    And I should see "10101"
    And I am logged out
    And I am logged in as "new_user@example.com"
    And I am on the "landing" page
    And I click on t("menus.nav.members.manage_company.edit_company")
    Then I should see t("companies.edit.title", company_name: "")
    And I should see t("companies.company_name")
    And I should see t("companies.show.company_number")
    And I should see t("companies.telephone_number")
    And I should see t("companies.show.email")
    And I should see t("companies.show.website")
    Then I click on the second t("companies.view_company") link
    Then I click on t("companies.show.add_address")
    And I should see t("companies.show.street")
    And I should see t("companies.show.post_code")
    And I should see t("companies.show.city")
    And I should see t("companies.show.kommun")
    And I should see t("companies.show.region")
