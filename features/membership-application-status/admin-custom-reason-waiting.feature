Feature: "Other/Custom" waiting reason comes from locale file and Admin cannot edit or delete it

  As an Admin
  Because the "Other/custom" reason needs to always exist so that the UI (e.g. view) can use it to display a custom text field if it's chosen,
  And because the text displayed must be always translated,
  The text displayed for "Other/custom" reason must always come from a locale file

  PT: https://www.pivotaltracker.com/story/show/143810729
  PT: https://www.pivotaltracker.com/epic/show/3619113 (epic)


  This requires a different background set-up than the "admin-manage-reasons..." feature.
  This requires that the system be seeded *before* any other information is entered (via other background statements).


  Background:

    # it is important that this statement is first so that tables are empty, so that things will be seeded
    # Given the system is seeded with initial data


    Given the following users exists
      | first_name      | email                                  | admin |
      | AnnaWaiting     | anna_waiting_for_info@nosnarkybarky.se |       |
      | AnnaUnderReview | anna_under_review@nosnarkybarky.se     |       |
      | EmmaAccepted    | emma@happymutts.se                     |       |
      | admin           | admin@shf.se                           | true  |

    Given the following business categories exist
      | name  | description           |
      | rehab | physcial rehabitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name                 | company_number | email                 | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se | Stockholm |
      | HappyMutts           | 2120000142     | woof@happymutts.com   | Stockholm |


    And the following applications exist:
      | user_email                             | company_number | category_name | state                 |
      | anna_waiting_for_info@nosnarkybarky.se | 5560360793     | rehab         | waiting_for_applicant |
      | anna_under_review@nosnarkybarky.se     | 5560360793     | rehab         | under_review          |
      | emma@happymutts.se                     | 2120000142     | rehab         | accepted              |


    And the following member app waiting reasons exist:
      | name_sv | name_en | description_sv | description_en | is_custom |
      | namn 1  | name 1  | beskrivning 1  | description 1  | false     |
      | namn 2  | name 2  | beskrivning 2  | description 2  | false     |


    And I am logged in as "admin@shf.se"


  @admin @javascript
  Scenario: The "other/custom" reason is listed as a reason for the 'waiting for...' status
    Given I am on "AnnaWaiting" application page
    Then "member_app_waiting_reasons" should have t("admin_only.member_app_waiting_reasons.other_custom_reason") as an option

  @admin @javascript
  Scenario: "other/custom" reason is listed when the state is changed TO 'waiting for applicant'
    Given I am on "AnnaUnderReview" application page
    When I click on t("membership_applications.ask_applicant_for_info_btn")
    Then "member_app_waiting_reasons" should have t("admin_only.member_app_waiting_reasons.other_custom_reason") as an option

  @admin @javascript
  Scenario: "other/custom" reason is listed when the language is changed
    Given I am on "AnnaWaiting" application page
    Then "member_app_waiting_reasons" should have t("admin_only.member_app_waiting_reasons.other_custom_reason") as an option


  @admin @javascript
  Scenario: The "other/custom" reason doesn't appear in the list of all reasons
    Given I am on the "all waiting for info reasons" page
    Then I should see 2 reasons listed
    And I should not see t("admin_only.member_app_waiting_reasons.other_custom_reason")
