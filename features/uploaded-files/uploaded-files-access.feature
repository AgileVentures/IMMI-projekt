Feature: Who can access uploaded files

  Who can see which uploaded files?  (access permission)

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                   | admin | membership_number | member | first_name | last_name |
      | emma-member@example.com |       | 1001              | true   | Emma       | Member    |
      | bob-user@example.com    |       |                   | false  | Bob        | User      |
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


  # ===============================================================================================

  Scenario: Visitors cannot see uploaded files page
    Given I am logged out
    When I am on the "my uploaded files" page
    Then I should see a message telling me I am not allowed to see that page


  Scenario: User can only see their own uploaded files
    Given I am logged in as "bob-user@example.com"
    When I am on the "my uploaded files" page
    Then I should not see a message telling me I am not allowed to see that page
    When I am on the "my uploaded files" page for "emma-member@example.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: Member can only see their own qualtification files
    Given I am logged in as "emma-member@example.com"
    When I am on the "my uploaded files" page
    Then I should not see a message telling me I am not allowed to see that page
    When I am on the "my uploaded files" page for "bob-user@example.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: Admin can see all uploaded files
    Given I am logged in as "admin@shf.se"
    When I am on the "my uploaded files" page
    Then I should not see a message telling me I am not allowed to see that page
    When I am on the "my uploaded files" page for "emma-member@example.com"
    Then I should not see a message telling me I am not allowed to see that page
    When I am on the "my uploaded files" page for "bob-user@example.com"
    Then I should not see a message telling me I am not allowed to see that page
