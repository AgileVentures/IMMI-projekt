Feature: Admin can view all uploaded files, delete, and edit descriptions

  As an Admin
  So that I can verify all of the files that have ever provided (uploaded) to SHF
  and so that I can keep that list up to date and correct,
  I need to see all of the files uploaded (including any by Admin)
  and delete any that need be (that aren't associated with an approved application),
  and update the description of any of the files


  Background:
    Given the date is set to "2018-06-06"
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                     | admin | membership_number | member | first_name | last_name |
      | emma-member@example.com   |       | 1001              | true   | Emma       | Member    |
      | lars-member@example.com   |       | 101               | true   | Lars       | Member    |
      | biff-rejected@example.com |       |                   | false  | Biff       | NotMember |
      | admin@shf.se              | true  |                   |        | Admin      | Admin     |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                   |
      | emma-member@example.com |
      | lars-member@example.com |

    And these files have been uploaded
      | user_email                | file name          | description                                       |
      | emma-member@example.com   | emma-image.jpg     | this belongs to Emma and goes with an application |
      | emma-member@example.com   | emma-picture.jpg   | some random picture                               |
      | lars-member@example.com   | lars-image.jpg     | this belongs to Lars                              |
      | biff-rejected@example.com | biff-image.png     | this belongs to Biff                              |
      | admin@shf.se              | specifications.txt | some text file uploaded by an admin               |


    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name        | company_number | email               | region    |
      | Happy Mutts | 5560360793     | woof@happymutts.com | Stockholm |
      | Bowsers     | 2120000142     | bark@bowsers.com    | Stockholm |

    And the following business categories exist
      | name     | description   |
      | Grooming | grooming dogs |

    And the following applications exist:
      | user_email                | contact_email                | company_number | state    | when_approved | categories | uploaded file names         |
      | lars-member@example.com   | lars-member@happymutts.com   | 5560360793     | accepted | 2018-05-13    | Grooming   | lars-image.jpg              |
      | emma-member@example.com   | emma-member@bowsers.com      | 2120000142     | accepted | 2018-01-03    | Grooming   | diploma.pdf, emma-image.jpg |
      | biff-rejected@example.com | biff-rejected@happymutts.com | 5560360793     | rejected |               | Grooming   | biff-image.png              |

    And the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |
      | lars-member@example.com | 2018-05-05 | 2019-05-04  | member_fee   | betald | none    |


    And I am logged in as "admin@shf.se"

  # ===============================================================================================

  # ---------------------------
  # Viewing Uploaded Files

  Example: Admin can view all uploaded files in one place
    When I am on the "list of uploaded files" page
    Then I should see t("uploaded_files.index.admin_title")
    And I should see t("uploaded_files.uploaded_files_list.owner")
    And I should see t("uploaded_files.uploaded_files_list.file_name")
    And I should see t("uploaded_files.uploaded_files_list.updated_at")
    And I should see t("uploaded_files.uploaded_files_list.description")
    And I should see t("uploaded_files.uploaded_files_list.file_size")
    And I should see t("uploaded_files.uploaded_files_list.associated_with_application")

    And I should see "diploma.pdf"
    And I should see "Godkänd - 2018-01-03" in the row for "diploma.pdf"
    And I should see "emma-image.jpg"
    And I should see "Godkänd - 2018-01-03" in the row for "emma-image.jpg"
    And I should see "emma-picture.jpg"
    And I should not see "Godkänd" in the row for "emma-picture.jpg"
    And I should see "lars-image.jpg"
    And I should see "Godkänd - 2018-05-13" in the row for "lars-image.jpg"
    And I should see "biff-image.png"
    And I should see "Avböjd - 2018-06-06" in the row for "biff-image.png"
    And I should see "specifications.txt" in the row for "Admin Admin"


  Example: Application info is a link to the Application page
    When I am on the "list of uploaded files" page
    Then I should see link "Godkänd - 2018-01-03" on the row with "diploma.pdf"
    Then I should see link "Godkänd - 2018-01-03" on the row with "image.jpg"

    When I click on first "Godkänd - 2018-01-03" link
    Then I should be on the "application" page for "emma-member@example.com"

    When I am on the "list of uploaded files" page
    And I click on first "Godkänd - 2018-05-13" link
    Then I should be on the "application" page for "lars-member@example.com"

    When I am on the "list of uploaded files" page
    And I click on first "Avböjd - 2018-06-06" link
    Then I should be on the "application" page for "biff-rejected@example.com"


  Rule: Once an application has been approved by SHF, it cannot be changed. (Else it would have to be
  reviewed again.)

    Example: Only files that can be changed have edit and delete icons
      When I am on the "list of uploaded files" page
      Then I should see "diploma.pdf"
      And I should see "emma-image.jpg"
      And I should see "emma-picture.jpg"
      And I should see "lars-image.jpg"
      And I should see "biff-image.png"
      And I should see "specifications.txt"

    # This file is associated with an approved application so cannot be changed or deleted
      And I should not see the icon with CSS class "fa-edit" for the row with "diploma.pdf"
      And I should not see the icon with CSS class "fa-trash-alt" for the row with "diploma.pdf"

    # This file is associated with an approved application so cannot be changed or deleted
      And I should not see the icon with CSS class "fa-edit" for the row with "emma-image.jpg"
      And I should not see the icon with CSS class "fa-trash-alt" for the row with "emma-image.jpg"

      And I should see the icon with CSS class "fa-edit" for the row with "emma-picture.jpg"
      And I should see the icon with CSS class "fa-trash-alt" for the row with "emma-picture.jpg"

    # This file is associated with an approved application so cannot be changed or deleted
      And I should not see the icon with CSS class "fa-edit" for the row with "lars-image.jpg"
      And I should not see the icon with CSS class "fa-trash-alt" for the row with "lars-image.jpg"

    # This file is associated with a rejected application so cannot be changed or deleted
      And I should not see the icon with CSS class "fa-edit" for the row with "biff-image.png"
      And I should not see the icon with CSS class "fa-trash-alt" for the row with "biff-image.png"

      And I should see the icon with CSS class "fa-edit" for the row with "specifications.txt"
      And I should see the icon with CSS class "fa-trash-alt" for the row with "specifications.txt"
