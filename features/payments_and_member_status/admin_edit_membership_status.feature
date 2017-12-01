Feature: As an admin
  I want to be able to change certain attributes associated with a member
  So that I have flexibility in managing membership status

  Background:
    Given the following users exist
      | email          | admin | is_member | membership_number |
      | emma@mutts.com |       | true      | 1001              |
      | admin@shf.se   | true  | true      | 1                 |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

  @selenium @time_adjust
  Scenario: Admin edits membership status
    Given the date is set to "2017-11-01"
    Given I am logged in as "admin@shf.se"
    Then I am on the "user details" page for "emma@mutts.com"
    And I should see t("Yes")
    And I should see "2017-12-31"
    Then I click on t("users.user.edit_member_status")
    And I should see t("users.user.edit_member_status")
    And I should see t("users.show.member")
    And I should see t("activerecord.attributes.payment.expire_date")
    And I should see t("activerecord.attributes.payment.notes")
    Then I select radio button t("No")
    And I select "2018" in select list "payment[expire_date(1i)]"
    Then I select "juni" in select list "payment[expire_date(2i)]"
    And I select "1" in select list "payment[expire_date(3i)]"
    And I fill in t("activerecord.attributes.payment.notes") with "This is a note regarding this member."
    Then I click on t("users.user.submit_button_label")
    And I should see t("No")
    And I should see "2018-06-01"
    And I should see "This is a note regarding this member."
