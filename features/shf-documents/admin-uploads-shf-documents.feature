Feature: Admin uploads meeting PDFs

  As an admin
  So that the members of the organization stay informed about their organization
  I need to upload meeting minutes

  Background:

    Given the following users exists
      | first_name | email               | admin |
      | Emma       | emma@happymutts.se |       |
      | Bob        | bob@snarkybarky.se  |       |
      | admin      | admin@shf.se        | true  |

    And the following companies exist:
      | name        | company_number | email               |
      | Happy Mutts | 2120000142     | bowwow@bowsersy.com |

    And the following applications exist:
      | user_email          | company_number | state    |
      | emma@happymutts.se  | 2120000142     | accepted |


    And I am logged in as "admin@shf.se"

  @admin
  Scenario: Upload a meeting PDF
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded diploma        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    When I click on t("submit") button
    Then I should see t("shf_documents.create.success", document_title: "Uploaded diploma")
    When I am on the "all SHF documents" page
    Then I should see "Uploaded diploma"

  @admin @sad_path
  Scenario: Try to upload a file with unacceptable content type [SAD PATH]
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded diploma        | some description              |
    And I choose a shf-document named "tred.exe" to upload
    When I click on t("submit") button
    Then I should see t("shf_documents.invalid_upload_type")
    When I am on the "all SHF documents" page
    Then I should not see "Uploaded diploma"


  @visitor
  Scenario: Visitor cannot upload a SHF document
    Given I am Logged out
    And I am on the "new SHF document" page
    Then I should see t("errors.not_permitted")

  @user
  Scenario: User cannot upload a SHF document
    Given I am logged in as "bob@snarkybarky.se"
    And I am on the "new SHF document" page
    Then I should see t("errors.not_permitted")

  @member
  Scenario: Member cannot upload a SHF document
    Given I am logged in as "emma@happymutts.se"
    And I am on the "new SHF document" page
    Then I should see t("errors.not_permitted")
