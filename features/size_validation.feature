Feature: Applicant uploads too large a file for their application
  As an applicant
  if I upload a too large file
  I need to get an understandable error-message
  PT: https://www.pivotaltracker.com/story/show/136316233

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                 | admin |
      | hans@new-applicant.se |       |
      | emma@happymutts.se    |       |

    And the following business categories exist
      | name         |
      | Groomer      |

    And the application file upload options exist

    And the following applications exist:
      | user_email         | company_number | state        |
      | emma@happymutts.se | 5562252998     | new |

    And the following companies exist:
      | name                 | company_number | email                  | region     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm  |

  @selenium
  Scenario: New application - Uploads a file that is too large
    Given I am logged in as "hans@new-applicant.se"
    And I am on the "submit new membership application" page

    When I fill in the form with data:
      | shf_application_company_number | shf_application_phone_number | shf_application_contact_email |
      | 5560360793                     | 031-1234567                  | applicant_2@random.com        |
    And I select "Groomer" Category
    And I select files delivery radio button "files_uploaded"

    And I choose a file named "diploma_huge.pdf" to upload for the application
    When I click on t("shf_applications.new.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should not see t("shf_applications.create.success")

  @selenium
  Scenario: New application - Uploads a file that is too large then uploads ok file
    Given I am logged in as "hans@new-applicant.se"
    And I am on the "submit new membership application" page

    When I fill in the form with data:
      | shf_application_company_number | shf_application_phone_number | shf_application_contact_email |
      | 5560360793                     | 031-1234567                  | applicant_2@random.com        |
    And I select "Groomer" Category
    And I select files delivery radio button "files_uploaded"

    And I choose a file named "diploma_huge.pdf" to upload for the application
    When I click on t("shf_applications.new.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")

    Then I choose a file named "diploma.pdf" to upload for the application
    And I select files delivery radio button "files_uploaded"
    When I click on t("shf_applications.edit.submit_button_label")
    And I should see t("shf_applications.update.success")

  @selenium
  Scenario: New application - Uploads a file just under the size limit
    Given I am logged in as "hans@new-applicant.se"
    And I am on the "submit new membership application" page
    When I fill in the form with data:
      | shf_application_company_number | shf_application_phone_number | shf_application_contact_email |
      | 5560360793                     | 031-1234567                  | applicant_2@random.com        |
    And I select "Groomer" Category
    And I select files delivery radio button "upload_now"
    And I choose a file named "upload-just-under-limit.pdf" to upload for the application
    When I click on t("shf_applications.new.submit_button_label")
    Then I should not see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should see t("shf_applications.create.success", email_address: applicant_2@random.com)

  @selenium
  Scenario: Existing application - Uploads a file that is too large
    Given I am logged in as "emma@happymutts.se"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload for the application
    And I select files delivery radio button "upload_now"
    When I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should not see t("shf_applications.update.success")

  @selenium
  Scenario: Existing application - Uploads a file that is too large then uploads ok file
    Given I am logged in as "emma@happymutts.se"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload for the application
    And I select files delivery radio button "upload_now"
    When I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should not see t("shf_applications.update.success")

    Then I choose a file named "diploma.pdf" to upload for the application
    When I click on t("shf_applications.edit.submit_button_label")

    And I should see t("shf_applications.update.success")

  @selenium
  Scenario: Existing application - Uploads a file just under the size limit
    Given I am logged in as "emma@happymutts.se"
    And I am on the "edit my application" page
    And I choose a file named "upload-just-under-limit.pdf" to upload for the application
    And I select files delivery radio button "upload_now"
    When I click on t("shf_applications.edit.submit_button_label")
    Then I should not see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large")
    And I should see t("shf_applications.update.success")

  @selenium
  Scenario: Size error message in English when locale = en
    Given I am logged in as "emma@happymutts.se"
    And I set the locale to "en"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload for the application
    And I select files delivery radio button "upload_now"
    When I click on t("shf_applications.edit.submit_button_label")
    Then I should not see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large", locale: :sv)
    And I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large", locale: :en)
    And I set the locale to "sv"

  @selenium
  Scenario: Size error message in sveriges when locale = sv
    Given I am logged in as "emma@happymutts.se"
    And I set the locale to "sv"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload for the application
    And I select files delivery radio button "upload_now"
    When I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large", locale: :sv)

  @selenium
  Scenario: Switching locales - Size error message in the right language
    Given I am logged in as "emma@happymutts.se"
    And I set the locale to "sv"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload for the application
    And I select files delivery radio button "upload_now"
    When I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large", locale: :sv)
    And I set the locale to "en"
    And I am on the "edit my application" page
    And I choose a file named "diploma_huge.pdf" to upload for the application
    And I select files delivery radio button "upload_now"
    When I click on t("shf_applications.edit.submit_button_label")
    Then I should not see t("activerecord.errors.models.uploaded_file.attributes.actual_file_file_size.file_too_large", locale: :sv)
    And I set the locale to "sv"
