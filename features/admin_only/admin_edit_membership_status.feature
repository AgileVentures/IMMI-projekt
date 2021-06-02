Feature: Admin edits membership status, dates, notes (membership info)

  As an admin
  I need to be able to change the membership status
  So that I can fix problems and grant or revoke membership for special reasons

  Background:
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                     | admin | membership_status | member | membership_number |
      | emma@mutts.com            |       | current_member    |true   | 1001              |
      | bad-member@mutts.com      |       | current_member    |true   |                   |
      | never-paid-user@mutts.com |       | not_a_member      |false  |                   |
      | admin@shf.se              | true  |                   |false  |                   |

    Given the following business categories exist
      | name  | description                     |
      | groom | grooming dogs from head to tail |
      | rehab | physical rehabilitation         |

    Given the following applications exist:
      | user_email           | company_number | categories   | state    |
      | emma@mutts.com       | 5562252998     | rehab, groom | accepted |
      | bad-member@mutts.com | 5562252998     | rehab, groom | accepted |

    Given the following users have agreed to the Membership Ethical Guidelines:
      | email                     |
      | emma@mutts.com            |
      | bad-member@mutts.com      |
      | never-paid-user@mutts.com |

    Given the following payments exist
      | user_email           | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com       | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | bad-member@mutts.com | 2017-10-31 | 2018-10-30  | member_fee   | betald | none    |

    And the following memberships exist:
      | email                | first_day  | last_day   |
      | emma@mutts.com       | 2017-10-1  | 2017-12-31 |
      | bad-member@mutts.com | 2017-10-31 | 2018-10-30 |


    Given the date is set to "2017-11-01"

    Given I am logged in as "admin@shf.se"

  # -------------------------------------------------------------------------------------------

  @selenium @time_adjust
  Scenario: Admin edits membership last day and note
    Given I am on the "user details" page for "emma@mutts.com"
    Then the last day of membership for "emma@mutts.com" should be 2017-12-31
    When I click on t("users.user.edit_member_status")
    Then I should see t("users.user.edit_member_status")
    And I should see t("users.show.member")
    And I should see t("activerecord.attributes.membership.last_day")
    And I should see t("activerecord.attributes.membership.notes")
    When I select "2018" in select list "membership[last_day(1i)]"
    And I select "juni" in select list "membership[last_day(2i)]"
    And I select "1" in select list "membership[last_day(3i)]"
    And I fill in t("activerecord.attributes.membership.notes") with "Extended their membership to 1 juni 2018."
    And I click on t("users.user.submit_button_label")
    And I wait for all ajax requests to complete
    And I reload the page
    # ^^ should not have to do this - check later after upgrades. (DOM/page partial _is_ updated in real life, but not with capybara)
    Then I should see "Extended their membership to 1 juni 2018."
    And the last day of membership for "emma@mutts.com" should be 2018-06-01


  @selenium
  Scenario: Admin changes the last day and it is before today so the member is no longer a member
    Given the date is set to "2017-11-01"
    And I am on the "user details" page for "emma@mutts.com"
    Then the last day of membership for "emma@mutts.com" should be 2017-12-31
    And "emma@mutts.com" should be a member
    When I click on t("users.user.edit_member_status")
    Then I should see t("users.user.edit_member_status")
    And I should see t("users.show.member")
    And I should see t("activerecord.attributes.membership.last_day")
    And I should see t("activerecord.attributes.membership.notes")
    When I select "2017" in select list "membership[last_day(1i)]"
    And I select "september" in select list "membership[last_day(2i)]"
    And I select "1" in select list "membership[last_day(3i)]"
    And I click on t("users.user.submit_button_label")
    And I wait for all ajax requests to complete
    And I reload the page
    # ^^ should not have to do this - check later after upgrades. (DOM/page partial _is_ updated in real life, but not with capybara)
    Then the last day of membership for "emma@mutts.com" should be 2017-09-01
    And "emma@mutts.com" should not be a member


  @selenium
  Scenario: Admin changes membership status from member to not a member
    Given I am on the "user details" page for "bad-member@mutts.com"
    Then "bad-member@mutts.com" should be a current member
    And the last day of membership for "bad-member@mutts.com" should be 2018-10-30
    When I click on t("users.user.edit_member_status")
    Then I should see t("users.user.edit_member_status")
    And I should see t("users.show.member")
    And I should see t("activerecord.attributes.membership.last_day")
    And I should see t("activerecord.attributes.membership.notes")
    When I select radio button t("No")
    And I click on t("users.user.submit_button_label")
    And I wait for all ajax requests to complete
    And I reload the page
    # ^^ should not have to do this - check later after upgrades. (DOM/page partial _is_ updated in real life, but not with capybara)

    Then I should be on the "user account" page for "bad-member@mutts.com"
    And "bad-member@mutts.com" should not be a member
    And I should see t("users.show_for_applicant.title")
    And I should see t("users.show_for_applicant.pay_membership")


  @selenium
  Scenario: Admin changes not a member to a member
    Given I am on the "user account" page for "bad-member@mutts.com"
    When I click on t("users.user.edit_member_status")
    Then I should see t("users.user.edit_member_status")
    And I should see t("users.show.member")
    When I select radio button t("Yes")
#    And I fill in t("activerecord.attributes.membership.notes") with "Changed to IS a member."
    And I click on t("users.user.submit_button_label")
    And I wait for all ajax requests to complete
    And I reload the page
    # ^^ should not have to do this - check later after upgrades. (DOM/page partial _is_ updated in real life, but not with capybara)

    Then I should be on the "user account" page for "bad-member@mutts.com"
    And I should see t("users.show.is_a_member")
    And "bad-member@mutts.com" should be a member
#    And I should see "Changed to IS a member."


#  @selenium
#  Scenario: Admin changes not a member to a member and sets a specific last day

