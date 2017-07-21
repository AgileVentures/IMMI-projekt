Feature: Admin can delete uploaded SHF Documents

  As an admin
  So that I can get rid of SHF documents that shouldn't have been uploaded
  I need to be able to delete a SHF document


  Background:


    Given the following users exists
      | first_name | email              | admin |
      | Emma       | emma@happymutts.se |       |
      | Bob        | bob@snarkybarky.se |       |
      | admin      | admin@shf.se       | true  |

    And the following companies exist:
      | name        | company_number | email               |
      | Happy Mutts | 2120000142     | bowwow@bowsersy.com |

    And the following applications exist:
      | user_email         | company_number | state    |
      | emma@happymutts.se | 2120000142     | accepted |

    And I am logged in as "admin@shf.se"


  @admin @poltergeist
  Scenario:  Admin can delete a SHF document - confirm delete
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | doc 1                   | description 1                 |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | doc 2                   | description 2                 |
    And I choose a shf-document named "image.jpg" to upload
    And I click on t("submit") button
    Given I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | doc 3                   | description 3                 |
    And I choose a shf-document named "image.png" to upload
    And I click on t("submit") button
    And I am on the "all shf documents" page
    And I should see 3 shf-documents listed
    And I should see t("delete")
    When I click the t("delete") action for the row with "doc 1"
    And I confirm popup
    Then I should see t("shf_documents.destroy.success", document_title: "doc 1")
    And I should see 2 shf-documents listed
    And I should not see "description 1"

