Feature: Admin can edit details about an uploaded SHF Document

  As an admin
  So that I can keep information about uploaded SHF Documents up to date and helpful
  I need to be able to edit details about uploaded SHF Documents


  Background:


    Given the following users exists
      | first_name | email               | admin |
      | Emma       | emma@happymutts.se  |       |
      | Bob        | bob@snarkybarky.se  |       |
      | admin      | admin@shf.se        | true  |

    And the following companies exist:
      | name        | company_number | email               |
      | Happy Mutts | 2120000142     | bowwow@bowsersy.com |

    And the following applications exist:
      | user_email          | company_number | state    |
      | emma@happymutts.se | 2120000142     | accepted |

    And I am logged in as "admin@shf.se"


  @admin
  Scenario:  Admin can edit a SHF document - change the file uploaded
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am on the edit SHF document page for "Uploaded document"
    And I choose a shf-document named "image.png" to upload
    When I click on t("submit") button
    Then I should see t("shf_documents.update.success", document_title: "Uploaded document")
    And I should be on the SHF document page for "Uploaded document"
    And I should see "image.png"
    And I should not see "diploma.pdf"


  @admin
  Scenario:  Admin can edit a SHF document - change the title
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am on the edit SHF document page for "Uploaded document"
    And I fill in t("shf_documents.edit.title") with "Changed title"
    When I click on t("submit") button
    Then I should see t("shf_documents.update.success", document_title: "Changed title")
    And I should be on the SHF document page for "Changed title"
    And I should see "Changed title"


  @admin
  Scenario:  Admin can edit a SHF document - change the description
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am on the edit SHF document page for "Uploaded document"
    And I fill in t("shf_documents.edit.description") with "Changed description"
    When I click on t("submit") button
    Then I should see t("shf_documents.update.success", document_title: "Uploaded document")
    And I should be on the SHF document page for "Uploaded document"
    And I should see "Changed description"


  @visitor
  Scenario: Visitor cannot upload a SHF document
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am logged out
    When I am on the edit SHF document page for "Uploaded document"
    Then I should see t("errors.not_permitted")

  @user
  Scenario: User cannot upload a SHF document
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am logged in as "bob@snarkybarky.se"
    When I am on the edit SHF document page for "Uploaded document"
    Then I should see t("errors.not_permitted")

  @member
  Scenario: Member cannot upload a SHF document
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am logged in as "emma@happymutts.se"
    When I am on the edit SHF document page for "Uploaded document"
    Then I should see t("errors.not_permitted")
