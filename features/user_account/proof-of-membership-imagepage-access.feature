Feature: Who can see a member's Proof of Membership image html page, or download the jpg

  Anyone should be able to see a member's proof of membership html page
  and
  anyone should be able to download a member's proof of membership jpg image


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    # must have a SHF logo image that can be put into the proof of membership image
    Given the App Configuration is not mocked and is seeded

    Given the following users exist
      | email                | admin | member | membership_number | first_name | last_name |
      | admin@shf.se         | true  |        |                   | Admin      | Admin     |
      | member-emma@mutts.se |       | true   | 1001              | Emma       | Member    |
      | member-lars@mutts.se |       | true   | 1002              | Lars       | Member    |


    Given the following business categories exist
      | name  | description                                    |
      | groom | grooming dogs from head to tail and back again |

    Given the following applications exist:
      | user_email           | company_number | categories | state    |
      | member-emma@mutts.se | 5562252998     | groom      | accepted |
      | member-lars@mutts.se | 5562252998     | groom      | accepted |

    Given the date is set to "2017-11-01"

    Given the following payments exist
      | user_email           | start_date | expire_date | payment_type | status | hips_id |
      | member-emma@mutts.se | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | member-lars@mutts.se | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |


  Scenario: An admin can see a member's proof of membership image
    Given I am logged in as "admin@shf.se"
    And I am on the "proof of membership html image" page for "member-emma@mutts.se"
    Then I should see t("users.proof_of_membership.proof_title")
    And I should see "1001"
    And I should see "Emma Member"
    When I am on the "proof of membership html image" page for "member-lars@mutts.se"
    Then I should see t("users.proof_of_membership.proof_title")
    And I should see "1002"
    And I should see "Lars Member"

  Scenario: A member can see their own proof of membership html page
    Given I am logged in as "member-emma@mutts.se"
    When I am on the "proof of membership html image" page for "member-emma@mutts.se"
    Then I should see t("users.proof_of_membership.proof_title")
    And I should see "Emma Member"
    And I should see "1001"

  Scenario: A member can see another member's proof of membership html page
    Given I am logged in as "member-emma@mutts.se"
    When I am on the "proof of membership html image" page for "member-lars@mutts.se"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see t("users.proof_of_membership.proof_title")
    And I should see "Lars Member"
    And I should see "1002"

  Scenario: A member can download another member's proof of membership jpg
    Given I am logged in as "member-emma@mutts.se"
    When I am on the "proof of membership jpg download" page for "member-lars@mutts.se"
    Then I should get a downloaded image with the filename "proof_of_membership.jpg"

  Scenario: A visitor can see a member's proof of membership html page
    Given I am logged out
    When I am on the "proof of membership html image" page for "member-lars@mutts.se"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see t("users.proof_of_membership.proof_title")
    And I should see "Lars Member"
    And I should see "1002"

  Scenario: A visitor can download a member's proof of membership jpg
    Given I am logged out
    When I am on the "proof of membership jpg download" page for "member-lars@mutts.se"
    Then I should get a downloaded image with the filename "proof_of_membership.jpg"
