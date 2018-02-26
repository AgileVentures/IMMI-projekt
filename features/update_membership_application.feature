Feature: SHF Application status is changed

  As an Admin
  In order to get members into SHF and get their money
  I need to be able to review their applications and ultimately accept or reject them

  PT: https://www.pivotaltracker.com/story/show/133950603


  Hide the search form so that we don't also get the list of applications found in the total counts



  Background:
    Given the following users exists
      | first_name      | email                                  | admin |
      | EmmaUnderReview | emma_under_review@happymutts.se        |       |
      | HansUnderReview | hans_under_review@happymutts.se        |       |
      | AnnaWaiting     | anna_waiting_for_info@nosnarkybarky.se |       |
      | LarsRejected    | lars_rejected@snarkybark.se            |       |
      | NilsAccepted    | nils_member@bowwowwow.se               |       |
      | Applicant1      | applicant_1@random.com                 |       |
      | Applicant2      | applicant_2@random.com                 |       |
      | NewNurdle       | new_nurdle@happymutts.se               |       |
      | admin           | admin@shf.se                           | true  |

    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | dog crooning | crooning to dogs                |
      | rehab        | physcial rehabitation           |


    Given the following companies exist:
      | name                 | company_number | email                 |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se |


    And the following applications exist:
      | user_email                             | company_number | categories   | state                 |
      | emma_under_review@happymutts.se        | 5562252998     | rehab        | under_review          |
      | hans_under_review@happymutts.se        | 5562252998     | dog grooming | under_review          |
      | anna_waiting_for_info@nosnarkybarky.se | 5560360793     | rehab        | waiting_for_applicant |
      | lars_rejected@snarkybark.se            | 0000000000     | rehab        | rejected              |
      | nils_member@bowwowwow.se               | 0000000000     | dog crooning | accepted              |
      | new_nurdle@happymutts.se               | 5562252998     | dog grooming | new                   |

    And I am logged in as "admin@shf.se"
    And time is frozen at 2016-12-16


  @user
  Scenario: Application submitter can see but not update the Application status
    Given I am Logged out
    And I am logged in as "emma_under_review@happymutts.se"
    Given I am on the "application" page for "emma_under_review@happymutts.se"
    And I should see status line with status t("shf_applications.under_review")
    And I should not see button t("shf_applications.accept_btn")
    And I should not see button t("shf_applications.reject_btn")


  # From new to...

  @selenium @admin
  Scenario: Admin starts reviewing a new application (from new to under_review)
    Given I am on the "application" page for "new_nurdle@happymutts.se"
    Then I should see "dog grooming"
    When I click on t("shf_applications.start_review_btn")
    Then I should see t("shf_applications.start_review.success")
    And I should see status line with status t("shf_applications.under_review")
    And I should not see t("shf_applications.update.enter_member_number")
    And I should see "dog grooming"
    When I am on the "landing" page
    And I hide the search form

    Then I should see 1 t("shf_applications.waiting_for_applicant")
    And I should see 3 t("shf_applications.under_review")
    And I should see 1 t("shf_applications.accepted")
    And I should see 1 t("shf_applications.rejected")




  # From under_review to...

  @selenium @admin @user
  Scenario: Admin requests more info from user (from under_review to 'waiting for applicant')
    Given I am on the "application" page for "emma_under_review@happymutts.se"
    Then I should see "rehab"
    When I click on t("shf_applications.ask_applicant_for_info_btn")
    Then I should see t("shf_applications.need_info.success")
    And I should see status line with status t("shf_applications.waiting_for_applicant")
    And I should not see t("shf_applications.update.enter_member_number")
    And I should see "rehab"
    When I am on the "landing" page
    And I hide the search form

    Then I should see 2 t("shf_applications.waiting_for_applicant")
    And I should see 1 t("shf_applications.under_review")
    And I should see 1 t("shf_applications.accepted")
    And I should see 1 t("shf_applications.rejected")
    And I am Logged out
    And I am logged in as "emma_under_review@happymutts.se"
    And I am on the "edit my application" page
    And I should see the checkbox with id "shf_application_marked_ready_for_review" unchecked

  @selenium @admin
  Scenario: Admin changed from under_review to accepted
    Given I am on the "application" page for "emma_under_review@happymutts.se"
    Then I should see "rehab"
    When I click on t("shf_applications.accept_btn")
    Then I should see t("shf_applications.accept.success")
    And I should see "rehab"
    When I am on the "landing" page
    And I hide the search form

    Then I should see 1 t("shf_applications.waiting_for_applicant")
    And I should see 1 t("shf_applications.under_review")
    And I should see 2 t("shf_applications.accepted")
    And I should see 1 t("shf_applications.rejected")

  @selenium @admin
  Scenario: Admin changed from under_review to rejected
    Given I am on the "application" page for "emma_under_review@happymutts.se"
    Then I should see "rehab"
    When I click on t("shf_applications.reject_btn")
    Then I should see t("shf_applications.reject.success")
    And I should see status line with status t("shf_applications.rejected")
    And I should not see t("shf_applications.update.enter_member_number")
    And I should see "rehab"
    When I am on the "landing" page
    And I hide the search form

    Then I should see 1 t("shf_applications.waiting_for_applicant")
    And I should see 1 t("shf_applications.under_review")
    And I should see 2 t("shf_applications.rejected")
    And I should see 1 t("shf_applications.accepted")

  @admin
  Scenario: Admin cannot change from under_review to 'cancel waiting for applicant'
    Given I am on the "application" page for "emma_under_review@happymutts.se"
    Then I should not see button t("shf_applications.cancel_waiting_for_applicant_btn")

  @selenium @admin
  Scenario: Admin rejects an application (under_review to rejected)
    Given I am on the "application" page for "emma_under_review@happymutts.se"
    Then I should see "rehab"
    When I click on t("shf_applications.reject_btn")
    Then I should see t("shf_applications.reject.success")
    And I should see status line with status t("shf_applications.rejected")
    And I should not see t("shf_applications.update.enter_member_number")
    And I should see "rehab"
    When I am on the "landing" page
    And I hide the search form

    Then I should see 2 t("shf_applications.rejected")
    And I should see 1 t("shf_applications.under_review")
    And I should see 1 t("shf_applications.waiting_for_applicant")
    And I should see 1 t("shf_applications.accepted")

  @admin @user
  Scenario: Admin rejects an application that had uploaded files (under_review to rejected)
    Given  I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.se"
    And I am on the "application" page for "anna_waiting_for_info@nosnarkybarky.se"
    And I should see "rehab"
    Then I click on t("shf_applications.ask_applicant_for_info_btn")
    And  I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    And I am on the "edit my application" page
    And I choose a file named "image.png" to upload
    And I click on t("shf_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.se"
    And I am on the "application" page for "anna_waiting_for_info@nosnarkybarky.se"
    When I click on t("shf_applications.reject_btn")
    Then I should see t("shf_applications.reject.success")
    And I should see status line with status t("shf_applications.rejected")
    And I should see 0 uploaded files listed
    And I should not see "diploma.pdf"
    And I should not see "image.png"
    And I should see "rehab"

  # From waiting for applicant to...
  @member
  Scenario: Anna updates her application but doesn't mark it as ready to be reviewed yet
    Given I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    And I am on the "edit my application" page
    Then I should see the checkbox with id "shf_application_marked_ready_for_review" unchecked
    And I fill in t("shf_applications.show.last_name") with "ForInfo"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should not see status line with status t("shf_applications.ready_for_review")


  @selenium @user @admin
  Scenario: Anna marks her application as ready to be reviewed again
    Given I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    And I am on the "edit my application" page
    Then I should see the checkbox with id "shf_application_marked_ready_for_review" unchecked
    And I fill in t("shf_applications.show.last_name") with "ForInfo"
    When I check the checkbox with id "shf_application_marked_ready_for_review"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should see status line with status t("shf_applications.ready_for_review")
    And I am Logged out
    And I am logged in as "admin@shf.se"
    And I am on the "application" page for "anna_waiting_for_info@nosnarkybarky.se"
    Then I should see status line with status t("shf_applications.ready_for_review")
    And I should see "rehab"
    And I am on the "landing" page
    And I hide the search form

    And I should see 1 t("shf_applications.ready_for_review")
    And I should see 1 t("shf_applications.accepted")
    And I should see 2 t("shf_applications.under_review")
    And I should see 1 t("shf_applications.rejected")

  @selenium @admin
  Scenario: Admin changed from 'waiting for applicant' to 'under review'
    Given I am on the "application" page for "anna_waiting_for_info@nosnarkybarky.se"
    And I should see "rehab"
    When I click on t("shf_applications.cancel_waiting_for_applicant_btn")
    Then I should see t("shf_applications.cancel_need_info.success")
    And I should see status line with status t("shf_applications.under_review")
    And I should not see t("shf_applications.waiting_for_applicant")
    And I should not see t("shf_applications.update.enter_member_number")
    And I should see "rehab"
    When I am on the "landing" page
    And I hide the search form

    And I should see 3 t("shf_applications.under_review")
    And I should see 0 t("shf_applications.waiting_for_applicant")
    And I should see 1 t("shf_applications.accepted")
    And I should see 1 t("shf_applications.rejected")

  @admin
  Scenario: Admin cannot change from 'waiting for applicant' to rejected
    Given I am on the "application" page for "anna_waiting_for_info@nosnarkybarky.se"
    Then I should not see button t("shf_applications.reject_btn")

  @admin
  Scenario: Admin cannot change from 'waiting for applicant' to accepted
    Given I am on the "application" page for "anna_waiting_for_info@nosnarkybarky.se"
    Then I should not see button t("shf_applications.accept_btn")

  @admin
  Scenario: Admin cannot change from 'waiting for applicant' to 'waiting for applicant'
    Given I am on the "application" page for "anna_waiting_for_info@nosnarkybarky.se"
    Then I should not see t("shf_applications.ask_applicant_for_info_btn")


  @admin
  Scenario: 'Waiting for applicant' status is not changed if admin edits the application
    Given I am on the "application" page for "anna_waiting_for_info@nosnarkybarky.se"
    And I click on t("shf_applications.edit_shf_application")
    And I fill in t("shf_applications.show.last_name") with "AdminUpdated"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should see status line with status t("shf_applications.waiting_for_applicant")
    And I should not see status line with status t("shf_applications.under_review")


  # From accepted to...
  @selenium @admin
  Scenario: Admin changed from accepted to rejected
    Given I am on the "application" page for "nils_member@bowwowwow.se"
    And I should see "dog crooning"
    When I click on t("shf_applications.reject_btn")
    Then I should see t("shf_applications.reject.success")
    And I should see status line with status t("shf_applications.rejected")
    And I should see "dog crooning"
    When I am on the "landing" page
    And I hide the search form

    And I should see 2 t("shf_applications.under_review")
    And I should see 1 t("shf_applications.waiting_for_applicant")
    And I should see 0 t("shf_applications.accepted")
    And I should see 2 t("shf_applications.rejected")

  @admin
  Scenario: Admin cannot change from accepted to accepted
    Given I am on the "application" page for "nils_member@bowwowwow.se"
    Then I should not see button t("shf_applications.accept_btn")

  @admin
  Scenario: Admin cannot change from accepted to 'waiting for applicant'
    Given I am on the "application" page for "nils_member@bowwowwow.se"
    Then I should not see button t("shf_applications.ask_applicant_for_info_btn")
    Then I should not see button t("shf_applications.accept_btn")
    And I should not see button t("shf_applications.ask_applicant_for_info_btn")
    And I should not see button t("shf_applications.cancel_waiting_for_applicant_btn")


  @admin
  Scenario: Admin cannot change from accepted to cancel waiting for applicant
    Given I am on the "application" page for "nils_member@bowwowwow.se"
    Then I should not see button t("shf_applications.cancel_waiting_for_applicant_btn")


  # From rejected to...
  @user
  Scenario: User can only view application if it's rejected, they cannot edit it
    Given I am logged in as "lars_rejected@snarkybark.se"
    And I am on the "application" page for "lars_rejected@snarkybark.se"
    Then I should see t("shf_applications.show.title", user_full_name: "LarsRejected Lastname")
    And I should not see t("shf_applications.edit.title")
    And I should see "rehab"

  @selenium @admin
  Scenario: Admin cannot edit an application if it is rejected
    Given I am on the "application" page for "lars_rejected@snarkybark.se"
    And I should see "rehab"
    When I click on t("shf_applications.edit_shf_application")
    And I fill in t("shf_applications.show.last_name") with "BadBadLars"
    And I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should see status line with status t("shf_applications.rejected")
    And I should see "rehab"
    When I am on the "landing" page
    And I hide the search form

    And I should see 2 t("shf_applications.under_review")
    And I should see 1 t("shf_applications.waiting_for_applicant")
    And I should see 1 t("shf_applications.accepted")
    And I should see 1 t("shf_applications.rejected")

  @admin
  Scenario: Admin cannot change from rejected to 'waiting for applicant'
    Given I am on the "application" page for "lars_rejected@snarkybark.se"
    Then I should not see button t("shf_applications.ask_applicant_for_info_btn")

  @selenium @admin
  Scenario: Admin changed from rejected to accepted
    Given I am on the "application" page for "lars_rejected@snarkybark.se"
    And I should see "rehab"
    When I click on t("shf_applications.accept_btn")
    Then I should see t("shf_applications.accept.success")
    And I should see "rehab"
    When I am on the "landing" page
    And I hide the search form

    Then I should see 1 t("shf_applications.waiting_for_applicant")
    And I should see 2 t("shf_applications.under_review")
    And I should see 2 t("shf_applications.accepted")
    And I should see 0 t("shf_applications.rejected")

  @admin
  Scenario: Admin cannot change from rejected to rejected
    Given I am on the "application" page for "lars_rejected@snarkybark.se"
    Then I should not see button t("shf_applications.reject_btn")

  @admin
  Scenario: Admin cannot change from rejected to cancel needs info
    Given I am on the "application" page for "lars_rejected@snarkybark.se"
    Then I should not see button t("shf_applications.cancel_waiting_for_applicant_btn")
