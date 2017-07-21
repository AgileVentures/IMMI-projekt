Feature: SHF members (and admins) can views board meeting minutes (SHF documents)
  As a member
  So that I keep up with the direction of this member-driven organization
  I need to see SHF board meeting minutes (Styrelseprotokoll)

  As an admin
  So that I can track and manage all SHF documents
  I need to see a list of all SHF documents and be abled to view and delete them.


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


  Scenario: An admin can see the list of SHF documents and click on title link
    Given I am logged in as "admin@shf.se"
    And I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded diploma        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    When I click on t("submit") button
    When I am on the "all SHF documents" page
    Then I should see "Uploaded diploma"
    And I should see "some description"
    And I should see t("shf_documents.index.instructions")
    And I should see t("shf_documents.index.view_details")
    And I should see t("delete")
    And I should see t("shf_documents.new_shf_minutes")
    Then I should see link "shf-document-link-1" with target = "_blank"
    And I click on "Uploaded diploma"
     # clicking on a document title will show or download the actual document



  Scenario: A member can see all SHF documents and click on title link
    Given I am logged in as "admin@shf.se"
    And I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded diploma        | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    When I click on t("submit") button
    And I am logged out
    And I am logged in as "emma@happymutts.se"
    And I am on the "all SHF documents" page
    Then I should see "Uploaded diploma"
    And I should see "some description"
    And I should see t("shf_documents.index.instructions")
    And I should not see t("shf_documents.index.view_details")
    And I should not see t("delete")
    And I should not see t("shf_documents.new_shf_document")
    Then I should see link "shf-document-link-1" with target = "_blank"
    And I click on "Uploaded diploma"
     # clicking on a document title will show or download the actual document


  Scenario: Can sort by title
    Given I am logged in as "admin@shf.se"
    And I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | 1 Doc                   | 1 description                 |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | 2 Doc                   | 2 description                 |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | 3 Doc                   | 3 description                 |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am logged out
    And I am logged in as "emma@happymutts.se"
    And I am on the "all SHF documents" page

    Then I should see "1 Doc"
    And I should see "2 Doc"
    And I should see "3 Doc"
    When I click on t("shf_documents.index.description")


  Scenario: A visitor cannot see SHF documents
    Given I am logged out
    And I am on the "all SHF documents" page
    Then I should see t("errors.not_permitted")


  Scenario: A user cannot see SHF documents
    Given I am logged in as "bob@snarkybarky.se "
    And I am on the "all SHF documents" page
    Then I should see t("errors.not_permitted")
