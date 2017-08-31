Feature: As an Admin
  So that we can accept or reject new Memberships,
  I need to review a Membership Application that has been submitted
  PT: https://www.pivotaltracker.com/story/show/133950343

  Secondary feature:
  As an admin
  In order to handle new member applications
  I need to be able to log in to an admin part of the site

  PT: https://www.pivotaltracker.com/story/show/133080839

  Background:
    Given the following users exists
      | first_name         | email                               | admin |
      | Emma               | emma@personal.com                   |       |
      | Emma               | emma@random.com                     |       |
      | Hans               | hans@random.com                     |       |
      | Anna               | anna_needs_info@random.com          |       |
      | LarsRejected       | lars_rejected@snarkybark.se         |       |
      | NilsApproved       | nils_member@bowwowwow.se            |       |
      | EmmaUnderReview    | emma_under_review@happymutts.se     |       |
      | HansReadyForReview | hans_ready_for_review@happymutts.se |       |
      | admin              | admin@shf.com                       | true  |


    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | dog grooming |
      | dog crooning |
      | rehab        |

    And the following companies exist:
      | name                 | company_number | email                 |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se |

    And the following applications exist:
      | user_email                          | contact_email   | company_number | state                 | categories   |
      | emma@personal.com                   | emma@cmpy.com   | 5562252998     | waiting_for_applicant | Psychologist |
      | hans@random.com                     |                 | 5560360793     | waiting_for_applicant | Psychologist |
      | anna_needs_info@random.com          |                 | 2120000142     | waiting_for_applicant | Psychologist |
      | lars_rejected@snarkybark.se         |                 | 0000000000     | rejected              | dog crooning |
      | nils_member@bowwowwow.se            |                 | 0000000000     | accepted              | Groomer      |
      | emma_under_review@happymutts.se     |                 | 5562252998     | under_review          | rehab        |
      | hans_ready_for_review@happymutts.se |                 | 5562252998     | ready_for_review      | dog grooming |


  @admin
  Scenario: Listing incoming Applications open for Admin
    Given I am logged in as "admin@shf.com"
    And I am on the list applications page
    Then I should see "7" applications
    And I should see 1 t("membership_applications.under_review")
    And I should see 1 t("membership_applications.accepted")
    And I should see 3 t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.rejected")
    And I click on "Lastname, Emma"
    Then I should be on the "application" page for "emma@personal.com"
    And I should see "Emma Lastname"
    And I should see "5562252998"
    And I should see status line with status t("membership_applications.waiting_for_applicant")


  @admin
  Scenario: Admin can see an application with one business categories given
    Given I am logged in as "admin@shf.com"
    And I am on the list applications page
    Then I should see "7" applications
    And I click on "Lastname, Hans"
    Then I should be on the "application" page for "hans@random.com"
    And I should see "Hans Lastname"
    And I should see "5560360793"
    And I should see t("membership_applications.new_status")
    And I should see "Psychologist"
    And I should not see "Trainer"
    And I should not see "Groomer"

  @admin
  Scenario: Admin can see an application with multiple business categories given
    Given I am logged in as "emma@personal.com"
    And I am on the "landing" page
    And I click on t("menus.nav.members.my_application")
    And I select "Trainer" Category
    And I select "Psychologist" Category
    And I click on t("membership_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.com"
    And I am on the list applications page
    Then I should see "7" applications
    And I click on "Lastname, Emma"
    Then I should be on the "application" page for "emma@personal.com"
    And I should see "Emma Lastname"
    And I should see "5562252998"
    And I should see "Trainer"
    And I should see "Psychologist"
    And I should not see "Groomer"
    And I should see "emma@personal.com"
    And I should see "emma@cmpy.com"

  @member
  Scenario: Approved member should see membership number
    Given I am logged in as "nils_member@bowwowwow.se"
    And I am on the "landing" page
    And I click on t("menus.nav.members.my_application")
    Then I should see t("membership_applications.show.membership_number")

  @user
  Scenario: Listing incoming Applications restricted for Non-admins
    Given I am logged in as "hans@random.com"
    And I am on the list applications page
    Then I should see t("errors.not_permitted")


  @admin
  Scenario: Clicking the edit button on show page
    Given I am logged in as "admin@shf.com"
    When I am on the "application" page for "nils_member@bowwowwow.se"
    Then I should see t("membership_applications.accepted")
    And I click on t("membership_applications.edit_membership_application")
    Then I should be on the "edit application" page for "nils_member@bowwowwow.se"

  @user
  Scenario: User does not see edit-link
    Given I am logged in as "emma@random.com"
    When I am on the "Landing" page
    Then I should see t("menus.nav.users.apply_for_membership")
    And I should not see t("menus.nav.users.my_application")


  @admin
  Scenario: Admin sees business categories for user under_review
    Given I am logged in as "admin@shf.se"
    When I am on the "application" page for "emma_under_review@happymutts.se"
    Then I should see "rehab"

  @admin
  Scenario: Admin sees business categories for user that is ready_for_review
    Given I am logged in as "admin@shf.se"
    When I am on the "application" page for "hans_ready_for_review@happymutts.se"
    Then I should see "dog grooming"

  @admin
  Scenario: Admin sees business categories for user that is waiting_for_applicant
    Given I am logged in as "admin@shf.se"
    When I am on the "application" page for "emma@personal.com"
    Then I should see "Psychologist"


  @admin
  Scenario: Admin sees business categories for user that is accepted
    Given I am logged in as "admin@shf.se"
    When I am on the "application" page for "nils_member@bowwowwow.se"
    Then I should see "Groomer"
