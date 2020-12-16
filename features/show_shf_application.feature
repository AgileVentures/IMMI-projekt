Feature: Show (view) SHF Applications

  As a User or Member,
  I need to be able to see my membership application

  As an Admin
  So that we can accept or reject new Memberships,
  I need to review a Membership Application that has been submitted
  PT: https://www.pivotaltracker.com/story/show/133950343

  Secondary feature:
  As an admin
  In order to handle new member applications
  I need to be able to log in to an admin part of the site

  PT: https://www.pivotaltracker.com/story/show/133080839

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | first_name         | email                               | admin |
      | Emma               | emma_waits@waiting.se               |       |
      | Emma               | emma@random.com                     |       |
      | Hans               | hans_waits@waiting.se               |       |
      | Anna               | anna_needs_info@waiting.se          |       |
      | RejectedLars       | lars_rejected@snarkybark.se         |       |
      | MemberMarkus       | markus_member@bowwowwow.se          |       |
      | UnderReviewEmma    | emma_under_review@happymutts.se     |       |
      | ReadyForReviewHans | hans_ready_for_review@happymutts.se |       |
      | NewNurdle          | new_nurdle@happymutts.se            |       |
      | admin              | admin@shf.se                        | true  |


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
      | user_email                          | contact_email | company_number | state                 | categories   |
      | emma_waits@waiting.se               | emma@cmpy.com | 5562252998     | waiting_for_applicant | Psychologist |
      | hans_waits@waiting.se               |               | 5560360793     | waiting_for_applicant | Psychologist |
      | anna_needs_info@waiting.se          |               | 2120000142     | waiting_for_applicant | Psychologist |
      | lars_rejected@snarkybark.se         |               | 0000000000     | rejected              | dog crooning |
      | markus_member@bowwowwow.se          |               | 0000000000     | accepted              | Groomer      |
      | emma_under_review@happymutts.se     |               | 5562252998     | under_review          | rehab        |
      | hans_ready_for_review@happymutts.se |               | 5562252998     | ready_for_review      | dog grooming |
      | new_nurdle@happymutts.se            |               | 5562252998     | new                   | dog grooming |


  @member
  Scenario: Approved member should see membership number
    Given I am logged in as "markus_member@bowwowwow.se"
    And I am on the "landing" page
    And I click on t("menus.nav.members.my_application")
    Then I should see t("shf_applications.show.membership_number")
    And I should not see t("shf_applications.show.files_delivery_method")

  @user
  Scenario: Listing incoming Applications restricted for Non-admins
    Given I am logged in as "hans_waits@waiting.se"
    And I am on the "membership applications" page
    Then I should see a message telling me I am not allowed to see that page


  @admin
  Scenario: Clicking the edit button on show page
    Given I am logged in as "admin@shf.se"
    When I am on the "application" page for "markus_member@bowwowwow.se"
    Then I should see t("activerecord.attributes.shf_application.state/accepted")
    And I click on t("shf_applications.edit_shf_application")
    Then I should be on the "edit application" page for "markus_member@bowwowwow.se"

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
    When I am on the "application" page for "emma_waits@waiting.se"
    Then I should see "Psychologist"


  @admin
  Scenario: Admin sees business categories for user that is accepted
    Given I am logged in as "admin@shf.se"
    When I am on the "application" page for "markus_member@bowwowwow.se"
    Then I should see "Groomer"


  @selenium, @user
  Scenario: User sees the status translated correctly (default locale, then :en, then :sv)
    Given I am logged in as "hans_waits@waiting.se"
    And I set the locale to "sv"
    When I am on the "application" page for "hans_waits@waiting.se"
    Then I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant")
    When I click on "change-lang-to-english"
    And I wait for 1 seconds
    Then I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :sv)
    When I click on "change-lang-to-svenska"
    And I wait for 1 seconds
    Then I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :sv)
    And I should not see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :en)


  @selenium, @member
  Scenario: Member sees the status translated correctly (default locale, then :en, then :sv)
    Given I am logged in as "markus_member@bowwowwow.se"
    And I set the locale to "sv"
    When I am on the "application" page for "markus_member@bowwowwow.se"
    Then I should see t("activerecord.attributes.shf_application.state/accepted")
    When I click on "change-lang-to-english"
    And I wait for 1 seconds
    Then I should see t("activerecord.attributes.shf_application.state/accepted", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/accepted", locale: :sv)
    When I click on "change-lang-to-svenska"
    And I wait for 1 seconds
    Then I should see t("activerecord.attributes.shf_application.state/accepted", locale: :sv)
    And I should not see t("activerecord.attributes.shf_application.state/accepted", locale: :en)


  @selenium, @admin
  Scenario: For the admin, the status is translated correctly for the default locale
    Given I am logged in as "admin@shf.se"
    When I am on the "application" page for "new_nurdle@happymutts.se"
    And I should see t("shf_applications.show.files_delivery_method")
    Then I should see t("activerecord.attributes.shf_application.state/new", locale: sv)
    When I am on the "application" page for "emma_under_review@happymutts.se"
    And I should see t("activerecord.attributes.shf_application.state/under_review")
    When I am on the "application" page for "markus_member@bowwowwow.se"
    And I should see t("activerecord.attributes.shf_application.state/accepted")
    When I am on the "application" page for "lars_rejected@snarkybark.se"
    And I should see t("activerecord.attributes.shf_application.state/rejected")
    When I am on the "application" page for "hans_waits@waiting.se"
    And I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant")
    When I am on the "application" page for "hans_ready_for_review@happymutts.se"
    And I should see t("activerecord.attributes.shf_application.state/ready_for_review")


  @selenium, @admin
  Scenario: For the admin, the status is translated correctly when changed to :en and then to :sv
    Given I am logged in as "admin@shf.se"
    And I set the locale to "sv"
    When I am on the "application" page for "new_nurdle@happymutts.se"
    When I click on "change-lang-to-english"
    Then I should see t("activerecord.attributes.shf_application.state/new", locale: en)
    When I am on the "application" page for "emma_under_review@happymutts.se"
    And I should see t("activerecord.attributes.shf_application.state/under_review", locale: :en)
    When I am on the "application" page for "markus_member@bowwowwow.se"
    And I should see t("activerecord.attributes.shf_application.state/accepted", locale: :en)
    When I am on the "application" page for "lars_rejected@snarkybark.se"
    And I should see t("activerecord.attributes.shf_application.state/rejected", locale: :en)
    When I am on the "application" page for "hans_waits@waiting.se"
    And I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :en)
    When I am on the "application" page for "hans_ready_for_review@happymutts.se"
    And I should see t("activerecord.attributes.shf_application.state/ready_for_review", locale: :en)
    When I click on "change-lang-to-svenska"
    When I am on the "application" page for "new_nurdle@happymutts.se"
    Then I should see t("activerecord.attributes.shf_application.state/new", locale: sv)
    When I am on the "application" page for "emma_under_review@happymutts.se"
    And I should see t("activerecord.attributes.shf_application.state/under_review", locale: :sv)
    When I am on the "application" page for "markus_member@bowwowwow.se"
    And I should see t("activerecord.attributes.shf_application.state/accepted", locale: :sv)
    When I am on the "application" page for "lars_rejected@snarkybark.se"
    And I should see t("activerecord.attributes.shf_application.state/rejected", locale: :sv)
    When I am on the "application" page for "hans_waits@waiting.se"
    And I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :sv)
    When I am on the "application" page for "hans_ready_for_review@happymutts.se"
    And I should see t("activerecord.attributes.shf_application.state/ready_for_review", locale: :sv)
