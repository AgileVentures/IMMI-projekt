Feature: As an admin
  so that a new member gets notified that they have been approved and can then fill out their info,
  when I change their status to approved,
  send them email notifying them,
  and create their Company if it doesn't already exist,
  and associate them with the company

  PT: https://www.pivotaltracker.com/story/show/135472437

  Background:
    Given the following users exists
      | email                 | admin |
      | emma@happymutts.se    |       |
      | hans@happymutts.se    |       |
      | anna@nosnarkybarky.se |       |
      | admin@shf.com         | true  |

    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | dog crooning | crooning to dogs                |
      | rehab        | physcial rehabitation           |

    Given the following regions exist:
      | name         |
      | Stockholm    |

    Given the following companies exist:
      | name                 | company_number | email                 | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se | Stockholm |


    And the following applications exist:
      | first_name | user_email            | company_number | category_name | state   |
      | Emma       | emma@happymutts.se    | 5562252998     | rehab         | under_review |
      | Hans       | hans@happymutts.se    | 5562252998     | dog grooming  | under_review |
      | Anna       | anna@nosnarkybarky.se | 5560360793     | rehab         | under_review |

    And I am logged in as "admin@shf.com"

  Scenario: Admin approves, no company exists so one is created
    Given I am on "Emma" application page
    When I click on t("membership_applications.accept_btn")
    And I should be on the edit application page for "Emma"
    And I should see t("membership_applications.accept.success")
    And I should see t("membership_applications.update.enter_member_number")
    And I fill in t("membership_applications.show.membership_number") with "901"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see t("membership_applications.accepted")
    And I should see "901"
    Then I can go to the company page for "5562252998"


  Scenario: Admin approves, member is added to existing company
    Given I am on "Anna" application page
    When I click on t("membership_applications.accept_btn")
    And I should be on the edit application page for "Anna"
    And I should see t("membership_applications.update.enter_member_number")
    And I fill in t("membership_applications.show.membership_number") with "902"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see t("membership_applications.accepted")
    And I should see "902"
    And I am on the "all companies" page
    And I should see "No More Snarky Barky"
    And I am Logged out
    And I am on the "landing" page
    And I should see "No More Snarky Barky"
    And I should see "rehab"
    And I am logged in as "anna@nosnarkybarky.se"
    And I am on the "landing" page
    Then I should see t("menus.nav.members.manage_company.submenu_title")
    And I am on the "edit my application" page for "anna@nosnarkybarky.se"
    Then I should see t("membership_applications.show.membership_number")
    And I should see "902"
    And I am on the "edit my company" page for "anna@nosnarkybarky.se"
    Then I should see "No More Snarky Barky"

  Scenario: Admin approves, but then rejects it
    Given I am on "Emma" application page
    When I click on t("membership_applications.accept_btn")
    And I should be on the edit application page for "Emma"
    And I should see t("membership_applications.update.enter_member_number")
    And I fill in t("membership_applications.show.membership_number") with "901"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see t("membership_applications.accepted")
    And I should see "901"
    When I am on "Emma" application page
    And I click on t("membership_applications.reject_btn")
    Then I should see status line with status t("membership_applications.rejected")
    And I am Logged out
    And I am on the "landing" page
    Then I should not see "5562252998"
    And I am logged in as "emma@happymutts.se"
    And I navigate to the edit page for "Emma"
    Then I should be on "Edit My Application" page
    And I should not see t("membership_applications.show.membership_number")


  Scenario: Member owes money so Admin cannot approve
    Given I am on "Emma" application page


  Scenario: things go wrong
