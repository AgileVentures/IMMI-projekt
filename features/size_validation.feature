Feature: As an applicant
  if I upload a too large file
  I need to get an understandable error-message
  PT: https://www.pivotaltracker.com/story/show/136316233

  Background:
    Given the following users exists
      | first_name | email                 | admin |
      | Hans       | hans@new_applicant.se |       |
      | Emma       | emma@happymutts.se    |       |

    And the following applications exist:
      | user_email         | company_number | state        |
      | emma@happymutts.se | 5560360793     | under_review |


  Scenario: New application - Uploads a file that is too large
    Given I am logged in as "hans@new_applicant.se"
    And I am on the "submit new membership application" page
    When I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Hans                                   | Newfoundland                          | 5560360793                                 | 031-1234567                              | applicant_2@random.com                    |
    And I choose a file named "diploma_huge.pdf" to upload
    When I click on t("membership_applications.new.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should not see t("membership_applications.create.success")


  Scenario: New application - Uploads a file just under the size limit
    Given I am logged in as "hans@new_applicant.se"
    And I am on the "submit new membership application" page
    When I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Hans                                   | Newfoundland                          | 5560360793                                 | 031-1234567                              | applicant_2@random.com                    |
    And I choose a file named "upload-just-under-limit.pdf" to upload
    When I click on t("membership_applications.new.submit_button_label")
    Then I should not see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should see t("membership_applications.create.success")


  Scenario: Existing application - Uploads a file that is too large
    Given I am logged in as "emma@happymutts.se"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload
    When I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should not see t("membership_applications.update.success")


  Scenario: Existing application - Uploads a file just under the size limit
    Given I am logged in as "emma@happymutts.se"
    And I am on the "edit my application" page
    And I choose a file named "upload-just-under-limit.pdf" to upload
    When I click on t("membership_applications.edit.submit_button_label")
    Then I should not see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should see t("membership_applications.update.success")


  Scenario: Size error message in English when locale = en
    Given I am logged in as "emma@happymutts.se"
    And I set the locale to "en"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload
    When I click on t("membership_applications.edit.submit_button_label")
    Then I should not see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large"), locale: :sv
    And I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large"), locale: :en
    And I set the locale to "sv"


  Scenario: Size error message in sveriges when locale = sv
    Given I am logged in as "emma@happymutts.se"
    And I set the locale to "sv"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload
    When I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large"), locale: :sv


  Scenario: Switching locales - Size error message in the right language
    Given I am logged in as "emma@happymutts.se"
    And I set the locale to "sv"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload
    When I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large"), locale: :sv
    And I set the locale to "en"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload
    When I click on t("membership_applications.edit.submit_button_label")
    Then I should not see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large"), locale: :sv
    And I set the locale to "sv"


