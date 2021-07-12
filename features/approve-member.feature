Feature: Admin approves a member

  As an admin
  so that a new member gets notified that they have been approved and can then fill out their info,
  when I change their status to approved,
  send them email notifying them,
  and create their Company if it doesn't already exist,
  and associate them with the company

  PT: https://www.pivotaltracker.com/story/show/135472437

  Background:
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                 | admin | password       |
      | emma@happymutts.se    |       | password       |
      | hans@happymutts.se    |       | password       |
      | anna@nosnarkybarky.se |       | password       |
      | admin@shf.com         | true  | admin_password |

    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | dog crooning | crooning to dogs                |
      | rehab        | physical rehabilitation         |

    And the application file upload options exist

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name                 | company_number | email                 | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se | Stockholm |

    And the following applications exist:
      | user_email            | company_number | categories   | state        |
      | emma@happymutts.se    | 5562252998     | rehab        | under_review |
      | hans@happymutts.se    | 5562252998     | dog grooming | under_review |
      | anna@nosnarkybarky.se | 5560360793     | rehab        | under_review |

    # ====================================================================================

  @selenium
  Scenario: Admin approves, no company exists so one is created
    Given I am logged in as "admin@shf.com"
    And I am on the "application" page for "emma@happymutts.se"
    When I click on t("shf_applications.accept_btn")
    And I should be on the "edit application" page for "emma@happymutts.se"
    And I should see t("shf_applications.accept.success")
    And I click on t("shf_applications.edit.submit_button_label")

    And I should see t("shf_applications.update.success_with_app_files_missing")

    And I should see t("shf_applications.accepted")
    Then I can go to the company page for "5562252998"

  @selenium
  Scenario: Admin approves, member is added to existing company
    Given I am in "admin@shf.com" browser
    And I am logged in as "admin@shf.com"
    Then I am on the "application" page for "anna@nosnarkybarky.se"
    When I click on t("shf_applications.accept_btn")
    And I should be on the "edit application" page for "anna@nosnarkybarky.se"
    And I should see t("shf_applications.show.membership_number")
    And I click on t("shf_applications.edit.submit_button_label")

    And I should see t("shf_applications.update.success_with_app_files_missing")

    And I should see t("shf_applications.accepted")
    And I am on the "all companies" page
    And I should see "No More Snarky Barky"
    And I am Logged out

    Then I am in "anna@nosnarkybarky.se" browser
    And I am logged in as "anna@nosnarkybarky.se"
    And I have agreed to all of the Membership Guidelines
    And I am on the "user account" page for "anna@nosnarkybarky.se"
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment

    Then I am on the "user account" page
    And I should see "No More Snarky Barky"

    #Then I should see t("my_company", count: "1.to_i")
    # ^^ removed because it went from visible (in expanded menu) to invisible
    #    (in hamburger menu) when this test is driven by a JS-capable driver

    And I am on the "show my application" page for "anna@nosnarkybarky.se"
    Then I should see t("shf_applications.show.membership_number")
    And I should not see "902"

    Then I am the page for company number "5560360793"
    Then I complete the branding payment for "No More Snarky Barky"

    Then I am on the "landing" page
    And I should see "No More Snarky Barky"
    And I should see "rehab"

    Then I am in "admin@shf.com" browser
    And I am logged in as "admin@shf.com"
    And I am on the "all users" page
    Then I click the icon with CSS class "edit" for the row with "anna@nosnarkybarky.se"

    And I fill in t("activerecord.attributes.user.membership_number") with "902"

    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    Then I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("admin_only.user_profile.update.success")

    And the t("activerecord.attributes.user.membership_number") field should be set to "902"

    Then I am in "anna@nosnarkybarky.se" browser
    And I am on the "application" page for "anna@nosnarkybarky.se"
    And I should see "902"

  @selenium
  Scenario: Admin approves, but then rejects it
    Given I am in "admin@shf.com" browser
    And I am logged in as "admin@shf.com"
    And I am on the "application" page for "emma@happymutts.se"
    When I click on t("shf_applications.accept_btn")
    And I click on t("shf_applications.edit.submit_button_label")

    Then I am in "emma@happymutts.se" browser
    And I am logged in as "emma@happymutts.se"
    And I have agreed to all of the Membership Guidelines
    And I am on the "user details" page for "emma@happymutts.se"
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment

    Then I am on the "user account" page
    And I should see t("activerecord.attributes.membership.status.current_member")
    
    Then I am in "admin@shf.com" browser
    And I reload the page

    And I am on the "all users" page
    Then I click the icon with CSS class "edit" for the row with "emma@happymutts.se"

    And I fill in t("activerecord.attributes.user.membership_number") with "901"
    And I fill in t("devise.registrations.edit.current_password") with "admin_password"
    Then I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("admin_only.user_profile.update.success")

    And the t("activerecord.attributes.user.membership_number") field should be set to "901"

    When I am on the "application" page for "emma@happymutts.se"
    And I click on t("shf_applications.reject_btn")
    Then I should see status line with status t("shf_applications.rejected")
    And I am Logged out
    And I am on the "landing" page
    Then I should not see "5562252998"

    Then I am in "emma@happymutts.se" browser
    And I am logged in as "emma@happymutts.se"
    And I am on the "show my application" page for "emma@happymutts.se"
    Then I should be on "show my application" page
    Then I should not see "901"
