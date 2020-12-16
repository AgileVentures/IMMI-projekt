Feature: Member uploads files not associated with a shf application

  As a member
  So that I can show SHF that I have continued to education myself
  I need to be able to upload additional files during the year,
  separate from submitting any new or additional application


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                   | admin | membership_number | member | first_name | last_name |
      | emma-member@example.com |       | 1001              | true   | Emma       | IsAMember |
      | admin@shf.se            | true  |                   |        |            |           |

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

    And the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |

    And I am logged in as "emma-member@example.com"

  # ===============================================================================================

  Scenario: Member uploads a single file
    When I am on the "upload a new file" page
    Then I should see t("uploaded_files.new.upload_button_title")
    And I should see t("activerecord.attributes.uploaded_file.description")
    When I choose a file named "biff-image.png" to upload
    And I fill in "uploaded_file_description" with "This is the description for the new file"
    And I click on t("save")
    Then I should see t("uploaded_files.create.success", file_name: 'biff-image.png')


  Scenario: Member tries to upload a file that is too big
    When I am on the "upload a new file" page
    And I choose a file named "diploma_huge.pdf" to upload
    And I click on t("save")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should not see t("uploaded_files.create.success", file_name: 'biff-image.png')
    When I am on the "my uploaded files" page
    Then I should not see "biff-image.png"


  Scenario: Member tries to upload a file type that is forbidden
    When I am on the "upload a new file" page
    And I choose a file named "tred.exe" to upload
    And I click on t("save")
    Then I should see t("uploaded_files.create.invalid_upload_type")
    And I should not see t("uploaded_files.create.success", file_name: 'biff-image.png')
    When I am on the "my uploaded files" page
    Then I should not see "tred.exe"
