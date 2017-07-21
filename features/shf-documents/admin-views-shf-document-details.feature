Feature: Admin can edit details about an uploaded SHF Document

  As an admin
  So that I can verify that the information about an uploaded SHF Document is correct
  I need to be able to view the details about an uploaded SHF Document


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
      | emma@happymutts.se | 2120000142      | accepted |

    And I am logged in as "admin@shf.se"


  @admin
  Scenario:  Admin can view all of the details for a SHF document
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am on the SHF document page for "Uploaded document"
    Then I should see "Uploaded document"
    And I should see "some description"
    And I should see "diploma.pdf"
    And I should see t("shf_documents.edit.uploaded_by")
    And I should see "admin@shf.se"
    And I should see t("shf_documents.edit.uploaded_on")



  @visitor
  Scenario: Visitor cannot view the details for a SHF document
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am logged out
    When I am on the SHF document page for "Uploaded document"
    Then I should see t("errors.not_permitted")

  @user
  Scenario: User cannot view the details for a SHF document
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am logged in as "bob@snarkybarky.se"
    When I am on the SHF document page for "Uploaded document"
    Then I should see t("errors.not_permitted")

  @member
  Scenario: Member cannot view the details for a SHF document
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am logged in as "emma@happymutts.se"
    When I am on the SHF document page for "Uploaded document"
    Then I should see t("errors.not_permitted")
