Feature: A member is returned to their account page after uploading a file from that page

  As a member,
  if I am on my account page and want to upload a new file,
  after I successfully upload the new file,
  I should be taken back to my account page
  So that I can continue my work flow
  and so that I do not have to figure out how to manually get back to my account page.


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                   | admin | membership_number | member | membership_status | first_name | last_name |
      | applicant-new@voof.se   |       |                   | false  | not_a_member      | New        | Applicant |
      | emma-member@example.com |       | 1001              | true   | current_member    | Emma       | IsAMember |
      | admin@shf.se            | true  |                   |        |                   |            |           |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                   |
      | emma-member@example.com |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name    | company_number | email            | region    |
      | Bowsers | 2120000142     | bark@bowsers.com | Stockholm |


    And the following business categories exist
      | name     | description   |
      | Grooming | grooming dogs |

    And the following applications exist:
      | user_email              | contact_email           | company_number | state    | categories |
      | emma-member@example.com | emma-member@bowsers.com | 2120000142     | accepted | Grooming   |
      | applicant-new@voof.se   | applicant-new@voof.se   | 2120000142     | new      | Grooming   |

    And the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id |
      | emma-member@example.com | 2021-01-1  | 2021-12-31  | member_fee   | betald | none    |

    And the following memberships exist:
      | email                   | first_day | last_day   |
      | emma-member@example.com | 2021-01-1 | 2021-12-31 |


    Given the date is set to "2021-06-06"

  # -----------------------------------------------------------------------------------------------


  Scenario: Member is on her account page, uploads a file, and is returned there after the upload
    Given I am logged in as "emma-member@example.com"
    And I am on the "user account" page
    When I click on t("users.uploaded_files_requirement.upload_file")
    Then I should see t("uploaded_files.new.title") in the h1 title

    When I choose a file named "biff-image.png" to upload
    And I fill in "uploaded_file_description" with "This is the description for the new file"
    And I click on t("save")
    Then I should see t("uploaded_files.create.success", file_name: 'biff-image.png')
    And I should be on the "user account" page for "emma-member@example.com"


  Scenario Outline: I am on the 'all my uploaded files' page and return there after uploading a file
#    Given I am logged in as ""
    Given I am logged in as "<user_email>"
    When I am on the "list of uploaded files" page
    When I click on t("uploaded_files.new.title")
    Then I should see t("uploaded_files.new.title") in the h1 title

    When I choose a file named "biff-image.png" to upload
    And I fill in "uploaded_file_description" with "This is the description for the new file"
    And I click on t("save")
    Then I should see t("uploaded_files.create.success", file_name: 'biff-image.png')
    And I should be on the "list of uploaded files" page

    Scenarios:
      | user_email              |
      | emma-member@example.com |
      | applicant-new@voof.se   |


