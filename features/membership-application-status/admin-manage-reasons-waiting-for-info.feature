Feature: Admin manages the list of reasons why SHF is waiting for info from an applicant

  As an Admin
  So that I can keep the list of reasons meaningful and usable to SHF Admins looking at membership applications
  I need to be able to add, edit, and delete the list of reasons why SHF is waiting for info from an applicant,
  including reviewing 'custom' (other) reasons that were entered by Admins and determining if they need to be
  permanently added to the list of reasons or removed from the list.


  PT: https://www.pivotaltracker.com/story/show/143810729


  Background:
    Given the following users exists
      | email                                  | admin |
      | anna_waiting_for_info@nosnarkybarky.se |       |
      | emma@happymutts.se                     |       |
      | admin@shf.se                           | true  |

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
      | emma@happymutts.se                     | 2120000142     | rehab         | accepted              |


    And the following member app waiting reasons exist:
      | name_sv | name_en | description_sv | description_en | is_custom |
      | namn 1  | name 1  | beskrivning 1  | description 1  | false     |
      | namn 2  | name 2  | beskrivning 2  | description 2  | false     |



  # Access: only an admin has access to this

  @visitor
  Scenario: a visitor cannot view the list of reasons
    Given I am logged out
    When I am on the "all waiting for info reasons" page
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.index.title")

  @user
  Scenario: A logged in user cannot view the list of reasons
    Given I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    When I am on the "all waiting for info reasons" page
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.index.title")


  @member
  Scenario: A member cannot view the list of reasons
    Given I am logged in as "emma@happymutts.se"
    When I am on the "all waiting for info reasons" page
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.index.title")


  @admin
  Scenario: An admin can view the list of reasons
    Given I am logged in as "admin@shf.se"
    When I am on the "all waiting for info reasons" page
    Then I should not see t("errors.not_permitted")
    And I should see t("admin_only.member_app_waiting_reasons.index.title")



  @visitor
  Scenario: A visitor cannot create a new reason
    Given I am logged out
    When I am on the "new waiting for info reason" page
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.new.title")

  @user
  Scenario: A logged in user cannot create a new reason
    Given I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    When I am on the "new waiting for info reason" page
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.new.title")


  @member
  Scenario: A member cannot create a new reason
    Given I am logged in as "emma@happymutts.se"
    When I am on the "new waiting for info reason" page
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.new.title")


  @admin
  Scenario: An admin can create a new reason
    Given I am logged in as "admin@shf.se"
    When I am on the "new waiting for info reason" page
    Then I should not see t("errors.not_permitted")
    And I should see t("admin_only.member_app_waiting_reasons.new.title")




  @visitor
  Scenario: A visitor cannot edit a reason
    Given I am logged out
    When I am on the edit member app waiting reason with name_sv "namn 1"
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.edit.title", name_sv: "namn 1", name_en: "name 1")

  @user
  Scenario: A logged in user cannot edit a reason
    Given I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    When I am on the edit member app waiting reason with name_sv "namn 1"
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.edit.title", name_sv: "namn 1", name_en: "name 1")


  @member
  Scenario: A member cannot edit a reason
    Given I am logged in as "emma@happymutts.se"
    When I am on the edit member app waiting reason with name_sv "namn 1"
    Then I should see t("errors.not_permitted")
    And I should not see t("admin_only.member_app_waiting_reasons.edit.title", name_sv: "namn 1", name_en: "name 1")


  @admin
  Scenario: An admin can edit a reason
    Given I am logged in as "admin@shf.se"
    When I am on the edit member app waiting reason with name_sv "namn 1"
    Then I should not see t("errors.not_permitted")
    And I should see t("admin_only.member_app_waiting_reasons.edit.title", name_sv: "namn 1", name_en: "name 1")



  # Basic CRUD and managing the reasons:

  @admin
  Scenario: Admin adds a new reason
    Given I am logged in as "admin@shf.se"
    When I am on the "all waiting for info reasons" page
    Then I should see 2 reasons listed
    And I click on "new-member-app-waiting-reason"
    Then I should see t("admin_only.member_app_waiting_reasons.new.title")
    And I should be on the "new waiting for info reason" page
    When I fill in the translated form with data:
      | activerecord.attributes.member_app_waiting_reason.name_sv | activerecord.attributes.member_app_waiting_reason.name_en | activerecord.attributes.member_app_waiting_reason.description_sv | activerecord.attributes.member_app_waiting_reason.description_en |
      | Namn på svenska                                           | Name in English                                           | Beskrivning på svenska                                           | Description in English                                           |
    And I click on t("save")
    And I should see t("admin_only.member_app_waiting_reasons.create.success")
    When I am on the "all waiting for info reasons" page
    Then I should see 3 reasons listed
    And I should see "Namn på svenska"


  @admin
  Scenario: Admin adds a new reason but leaves required name_sv blank (SAD PATH)
    Given I am logged in as "admin@shf.se"
    When I am on the "all waiting for info reasons" page
    Then I should see 2 reasons listed
    And I click on "new-member-app-waiting-reason"
    Then I should be on the "new waiting for info reason" page
    When I fill in the translated form with data:
      | activerecord.attributes.member_app_waiting_reason.name_en | activerecord.attributes.member_app_waiting_reason.description_sv | activerecord.attributes.member_app_waiting_reason.description_en |
      | Name in English                                           | Beskrivning på svenska                                           | Description in English                                           |
    And I click on t("save")
    When I am on the "all waiting for info reasons" page
    Then I should see 2 reasons listed
    And I should not see "Name in English"


  @admin
  Scenario: Admin deletes a reason
    Given I am logged in as "admin@shf.se"
    When I am on the "all waiting for info reasons" page
    Then I should see 2 reasons listed
    And I am on the member app waiting reason page for name_sv "namn 2"
    Then I should see "namn 2"
    And I should see "name 2"
    And I click on t("delete")
    Then I should see t("admin_only.member_app_waiting_reasons.destroy.success")
    And I should be on the "all member app waiting reasons" page
    And I should see 1 reasons listed
    And I should not see "namn 2"


  @admin
  Scenario: Admin deletes a reason from the list of reasons page
    Given I am logged in as "admin@shf.se"
    And I am on the "all waiting for info reasons" page
    Then I should see 2 reasons listed
    And I click the t("delete") action for the row with "namn 2"
    Then I should see t("admin_only.member_app_waiting_reasons.destroy.success")
    And I should not see "namn 2"


  @admin
  Scenario: Admin edits a reason
    Given I am logged in as "admin@shf.se"
    And I am on the edit member app waiting reason with name_sv "namn 1"
    And I fill in t("activerecord.attributes.member_app_waiting_reason.description_en") with "this is a long description in English"
    And I click on the t("save") button
    Then I should see t("admin_only.member_app_waiting_reasons.update.success")
    And I should see "this is a long description in English"
    And I should not see "description 1"


  Scenario: Admin edits a reason but leaves required field name_sv blank (SAD PATH)
    Given I am logged in as "admin@shf.se"
    And I am on the edit member app waiting reason with name_sv "namn 1"
    And I fill in t("activerecord.attributes.member_app_waiting_reason.name_sv") with ""
    And I fill in t("activerecord.attributes.member_app_waiting_reason.description_en") with "this is a long description in English"
    And I click on the t("save") button
    And I should not see "this is a long description in English"


  @admin
  Scenario: Admin changes a custom reason entered to a 'regular' reason on the list
    Given I am logged in as "admin@shf.se"
    And I am on the edit member app waiting reason with name_sv "namn 1"
    And I uncheck the checkbox with id "admin_only_member_app_waiting_reason_is_custom"
    And I click on the t("save") button
    Then I should see t("admin_only.member_app_waiting_reasons.update.success")
    And I should see t("no")
    And I should not see t("yes")


  @admin
  Scenario: Admin changes a regular reason to a custom reason
    Given I am logged in as "admin@shf.se"
    And I am on the edit member app waiting reason with name_sv "namn 1"
    And I check the checkbox with id "admin_only_member_app_waiting_reason_is_custom"
    And I click on the t("save") button
    Then I should see t("admin_only.member_app_waiting_reasons.update.success")
    And I should see t("yes")
    And I should not see t("no")
