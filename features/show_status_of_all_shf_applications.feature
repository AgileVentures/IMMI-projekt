Feature: Admin sees the status of applications on page of all SHF applications

  As an Admin
  In order to get an easy overview of all applications
  I need to see the status listed
  PT: https://www.pivotaltracker.com/story/show/134357317

  Background:
    Given the following users exists
      | email                         | admin |
      | new@mail.se                   |       |
      | under_review@mail.se          |       |
      | accepted@mail.se              |       |
      | rejected@mail.se              |       |
      | waiting_for_applicant@mail.se |       |
      | ready_for_review@mail.se      |       |
      | admin@shf.se                  | true  |

    And the following applications exist:
      | company_number | user_email                    | state                 |
      | 0000000000     | new@mail.se                   | new                   |
      | 5562252998     | under_review@mail.se          | under_review          |
      | 2120000142     | accepted@mail.se              | accepted              |
      | 0000000000     | rejected@mail.se              | rejected              |
      | 0000000000     | waiting_for_applicant@mail.se | waiting_for_applicant |
      | 0000000000     | ready_for_review@mail.se      | ready_for_review      |

    And I am logged in as "admin@shf.se"

  Scenario: Showing state in the application listing
    Given I am logged in as "admin@shf.se"
    And I am on the "membership applications" page
    Then I should see "6" applications
    And I should see t("shf_applications.index.state")
    And I should see t("activerecord.attributes.shf_application.state/new")
    And I should see t("activerecord.attributes.shf_application.state/under_review")
    And I should see t("activerecord.attributes.shf_application.state/accepted")
    And I should see t("activerecord.attributes.shf_application.state/rejected")
    And I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant")
    And I should see t("activerecord.attributes.shf_application.state/ready_for_review")

  @selenium
  Scenario: I18n - show status (states) in locale :sv and not in :en
    Given I am logged in as "admin@shf.se"
    And I set the locale to "sv"
    And I am on the "membership applications" page
    Then I should see "6" applications
    And I should see t("shf_applications.index.state")
    And I should see t("activerecord.attributes.shf_application.state/new", locale: :sv)
    And I should see t("activerecord.attributes.shf_application.state/under_review", locale: :sv)
    And I should see t("activerecord.attributes.shf_application.state/accepted", locale: :sv)
    And I should see t("activerecord.attributes.shf_application.state/rejected", locale: :sv)
    And I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :sv)
    And I should see t("activerecord.attributes.shf_application.state/ready_for_review", locale: :sv)
    And I should not see t("activerecord.attributes.shf_application.state/new", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/under_review", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/accepted", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/rejected", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/ready_for_review", locale: :en)


  @selenium
  Scenario: I18n - show status (states) in locale :en and not in :sv
    Given I am logged in as "admin@shf.se"
    And I set the locale to "en"
    # this seems to be required else the search menu loaded on the membership applications page may be loaded in :sv locale
    And I wait for 1 seconds
    And I am on the "shf applications" page
    Then I should see "6" applications
    And I should see t("shf_applications.index.state")
    And I should see t("activerecord.attributes.shf_application.state/new", locale: :en)
    And I should see t("activerecord.attributes.shf_application.state/under_review", locale: :en)
    And I should see t("activerecord.attributes.shf_application.state/accepted", locale: :en)
    And I should see t("activerecord.attributes.shf_application.state/rejected", locale: :en)
    And I should see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :en)
    And I should see t("activerecord.attributes.shf_application.state/ready_for_review", locale: :en)
    #And I should not see "Ny"  this will find any words that end with "ny" and so will fail.
    And I should not see t("activerecord.attributes.shf_application.state/under_review", locale: :sv)
    And I should not see t("activerecord.attributes.shf_application.state/accepted", locale: :sv)
    And I should not see t("activerecord.attributes.shf_application.state/rejected", locale: :sv)
    And I should not see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :sv)
    And I should not see t("activerecord.attributes.shf_application.state/ready_for_review", locale: :sv)
