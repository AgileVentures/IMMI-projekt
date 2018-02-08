Feature: Admin can see all SHF applications so they can be managed

  As an Admin
  So that I can manage and keep track of all SHF membership applications
  I need to see the list of all SHF applications

  PT: https://www.pivotaltracker.com/story/show/133080839

  Background:
    Given the following users exists
      | first_name         | email                               | admin |
      | Emma               | emma@personal.com                   |       |
      | Emma               | emma_waits@waiting.se               |       |
      | Hans               | hans_waits@waiting.se               |       |
      | Anna               | anna_needs_info@random.com          |       |
      | RejectedLars       | lars_rejected@snarkybark.se         |       |
      | ApprovedNils       | markus_member@bowwowwow.se          |       |
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
      | anna_needs_info@random.com          |               | 2120000142     | waiting_for_applicant | Psychologist |
      | lars_rejected@snarkybark.se         |               | 0000000000     | rejected              | dog crooning |
      | markus_member@bowwowwow.se          |               | 0000000000     | accepted              | Groomer      |
      | emma_under_review@happymutts.se     |               | 5562252998     | under_review          | rehab        |
      | hans_ready_for_review@happymutts.se |               | 5562252998     | ready_for_review      | dog grooming |
      | new_nurdle@happymutts.se            |               | 5562252998     | new                   | dog grooming |


  @admin
  Scenario: Listing shows the necessary columns for Admin
    Given I am logged in as "admin@shf.se"
    And I am on the "membership applications" page
    Then I should see t("shf_applications.index.membership_number")
    And I should see t("shf_applications.index.name")
    And I should see t("shf_applications.index.org_nr")
    And I should see t("shf_applications.index.state")
    And I should see t("manage")

  @selenium @admin
  Scenario: Listing all SHF Applications for  Admin
    Given I am logged in as "admin@shf.se"
    And I set the locale to "sv"
    And I am on the "membership applications" page
    And I hide the search form

    Then I should see "8" applications
    And I should see 1 t("activerecord.attributes.shf_application.state/under_review")
    And I should see 1 t("activerecord.attributes.shf_application.state/accepted")
    And I should see 3 t("activerecord.attributes.shf_application.state/waiting_for_applicant")
    And I should see 1 t("activerecord.attributes.shf_application.state/rejected")
    And I click the t("shf_applications.index.manage") action for the row with "Lastname, Emma"
    Then I should be on the "application" page for "emma_waits@waiting.se"
    And I should see "Emma Lastname"
    And I should see "5562252998"
    And I should see status line with status t("activerecord.attributes.shf_application.state/waiting_for_applicant")


  @admin
  Scenario: Admin can see an application with one business categories given
    Given I am logged in as "admin@shf.se"
    And I am on the "membership applications" page
    Then I should see "8" applications
    And I click the t("shf_applications.index.manage") action for the row with "Lastname, Hans"
    Then I should be on the "application" page for "hans_waits@waiting.se"
    And I should see "Hans Lastname"
    And I should see "5560360793"
    And I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant")
    And I should see "Psychologist"
    And I should not see "Trainer"
    And I should not see "Groomer"

  @admin
  Scenario: Admin can see an application with multiple business categories given
    Given I am logged in as "emma_waits@waiting.se"
    And I am on the "landing" page
    And I click on t("menus.nav.members.my_application")
    And I select "Trainer" Category
    And I select "Psychologist" Category
    And I click on t("shf_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.se"
    And I am on the "membership applications" page
    Then I should see "8" applications
    And I click the t("shf_applications.index.manage") action for the row with "Lastname, Emma"
    Then I should be on the "application" page for "emma_waits@waiting.se"
    And I should see "Emma Lastname"
    And I should see "5562252998"
    And I should see "Trainer"
    And I should see "Psychologist"
    And I should not see "Groomer"
    And I should see "emma_waits@waiting.se"
    And I should see "emma@cmpy.com"



  # --------------------
  # Access / Permission

  @visitor
  Scenario: Visitor cannot see the list of all SHF Applications (denied access)
    Given I am logged out
    When I am on the "shf applications" page
    Then I should see t("errors.not_permitted")
    And I should not see t("shf_applications.index.title")


  @user
  Scenario: User cannot see the list of all SHF Applications (denied access)
    Given I am logged in as "emma_under_review@happymutts.se"
    When I am on the "shf applications" page
    Then I should see t("errors.not_permitted")
    And I should not see t("shf_applications.index.title")


  @member
  Scenario: Member cannot see the list of all SHF Applications (denied access)
    Given I am logged in as "markus_member@bowwowwow.se"
    When I am on the "shf applications" page
    Then I should see t("errors.not_permitted")
    And I should not see t("shf_applications.index.title")

