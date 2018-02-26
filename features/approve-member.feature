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
      | rehab        | physical rehabilitation         |

    Given the following regions exist:
      | name         |
      | Stockholm    |

    Given the following companies exist:
      | name                 | company_number | email                 | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se | Stockholm |

    And the following applications exist:
      | user_email            | company_number | categories   | state        |
      | emma@happymutts.se    | 5562252998     | rehab        | under_review |
      | hans@happymutts.se    | 5562252998     | dog grooming | under_review |
      | anna@nosnarkybarky.se | 5560360793     | rehab        | under_review |

  Scenario: Admin approves, no company exists so one is created
    Given I am logged in as "admin@shf.com"
    And I am on the "application" page for "emma@happymutts.se"
    When I click on t("shf_applications.accept_btn")
    And I should be on the "edit application" page for "emma@happymutts.se"
    And I should see t("shf_applications.accept.success")
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should see t("shf_applications.accepted")
    Then I can go to the company page for "5562252998"

  Scenario: Admin approves, member is added to existing company
    Given I am in "admin@shf.com" browser
    And I am logged in as "admin@shf.com"
    Then I am on the "application" page for "anna@nosnarkybarky.se"
    When I click on t("shf_applications.accept_btn")
    And I should be on the "edit application" page for "anna@nosnarkybarky.se"
    And I should see t("shf_applications.show.membership_number")
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should see t("shf_applications.accepted")
    And I am on the "all companies" page
    And I should see "No More Snarky Barky"
    And I am Logged out
    And I am on the "landing" page
    And I should see "No More Snarky Barky"
    And I should see "rehab"

    Then I am in "anna@nosnarkybarky.se" browser
    And I am logged in as "anna@nosnarkybarky.se"
    And I am on the "user details" page for "anna@nosnarkybarky.se"
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the payment
    And I should see t("payments.success.success")
    Then I should see t("menus.nav.members.manage_company.submenu_title")
    And I am on the "show my application" page for "anna@nosnarkybarky.se"
    Then I should see t("shf_applications.show.membership_number")
    And I should not see "902"

    Then I am in "admin@shf.com" browser
    And I am logged in as "admin@shf.com"
    Then I am on the "application" page for "anna@nosnarkybarky.se"
    And I click on t("shf_applications.edit_shf_application")

    And I fill in t("shf_applications.show.membership_number") with "902"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should see "902"

    Then I am in "anna@nosnarkybarky.se" browser
    And I am on the "application" page for "anna@nosnarkybarky.se"
    And I should see "902"

  Scenario: Admin approves, but then rejects it
    Given I am in "admin@shf.com" browser
    And I am logged in as "admin@shf.com"
    And I am on the "application" page for "emma@happymutts.se"
    When I click on t("shf_applications.accept_btn")
    And I click on t("shf_applications.edit.submit_button_label")

    Then I am in "emma@happymutts.se" browser
    And I am logged in as "emma@happymutts.se"
    And I am on the "user details" page for "emma@happymutts.se"
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the payment
    And I should see t("payments.success.success")

    Then I am in "admin@shf.com" browser
    And I reload the page
    And I am on the "edit application" page for "emma@happymutts.se"

    And I fill in t("shf_applications.show.membership_number") with "901"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")

    And I should see "901"
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
