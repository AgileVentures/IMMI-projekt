Feature: Admin sets or enters the reason they are waiting for info from a user
  As an admin
  so that SHF can talk with the user specifically about why they are waiting and know how long they might need to wait,
  I need to set the reason why SHF is waiting
  and if the reason is not available from a list,
  I need to be able to type in text that describes the situation

  PT: https://www.pivotaltracker.com/story/show/143810729

  Background:
    Given the following users exists
      | email                                  | admin |
      | anna_waiting_for_info@nosnarkybarky.se |       |
      | admin@shf.com                          | true  |

    Given the following business categories exist
      | name  | description           |
      | rehab | physcial rehabitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name                 | company_number | email                 | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se | Stockholm |


    And the following applications exist:
      | first_name  | user_email                             | company_number | category_name | state                 |
      | AnnaWaiting | anna_waiting_for_info@nosnarkybarky.se | 5560360793     | rehab         | waiting_for_applicant |


    And I am logged in as "admin@shf.com"


  @javascript
  Scenario: Admin selects 'need more documentation' as the reason SHF is waiting_for_applicant
    Given I am on "AnnaWaiting" application page
    When I set "membership_application_reason_waiting" to t("membership_applications.need_info.reason.need_documentation")
    And I click on t("membership_applications.need_info.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And "membership_application_reason_waiting" should have t("membership_applications.need_info.reason.need_documentation") selected
    And item "membership_application_reason_waiting_custom_text" should not be visible


  @javascript
  Scenario: Admin selects 'waiting for payment' as the reason SHF is waiting_for_applicant
    Given I am on "AnnaWaiting" application page
    When I set "membership_application_reason_waiting" to t("membership_applications.need_info.reason.waiting_for_payment")
    And I click on t("membership_applications.need_info.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And "membership_application_reason_waiting" should have t("membership_applications.need_info.reason.waiting_for_payment") selected
    And item "membership_application_reason_waiting_custom_text" should not be visible


  @javascript
  Scenario: Admin selects 'other' and enters text as the reason SHF is waiting_for_applicant
    Given I am on "AnnaWaiting" application page
    When I set "membership_application_reason_waiting" to t("membership_applications.need_info.reason.custom_reason")
    And I fill in "membership_application_reason_waiting_custom_text" with "This is my reason"
    And I click on t("membership_applications.need_info.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And item "membership_application_reason_waiting_custom_text" should be visible
    And the "membership_application_reason_waiting_custom_text" field should be set to "This is my reason"
    And "membership_application_reason_waiting" should have t("membership_applications.need_info.reason.custom_reason") selected


  @javascript
  Scenario: Admin selects 'other' and fills in custom text but then changes reason to something else
    Given I am on "AnnaWaiting" application page
    When I set "membership_application_reason_waiting" to t("membership_applications.need_info.reason.custom_reason")
    And I fill in "membership_application_reason_waiting_custom_text" with "This is my reason"
    And I set "membership_application_reason_waiting" to t("membership_applications.need_info.reason.waiting_for_payment")
    And I click on t("membership_applications.need_info.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And "membership_application_reason_waiting" should have t("membership_applications.need_info.reason.waiting_for_payment") selected
    And item "membership_application_reason_waiting_custom_text" should not be visible


  @javascript
  Scenario: When selected reason is not 'custom other,' the custom text is saved as blank (empty string)
    Given I am on "AnnaWaiting" application page
    When I set "membership_application_reason_waiting" to t("membership_applications.need_info.reason.custom_reason")
    And I fill in "membership_application_reason_waiting_custom_text" with "This is my reason"
    And I set "membership_application_reason_waiting" to t("membership_applications.need_info.reason.waiting_for_payment")
    # change back so the custom reason field shows. it should be blank
    And I set "membership_application_reason_waiting" to t("membership_applications.need_info.reason.custom_reason")
    Then I should not see "This is my reason"

  @javascript
  Scenario: owner cannot see the fields for changing the reason
    Given I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    And I am on the application page for "AnnaWaiting"
    Then I should not see t("membership_applications.need_info.reason_title")
    And I should not see t("membership_applications.need_info.submit_button_label")
