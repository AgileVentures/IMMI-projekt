Feature: As an admin
  In order to understand and manage our user base
  I need to be able to view and make changes to user records

Background:
  Given the following users exist
    | email               | admin | is_member |
    | emma@happymutts.com |       | true      |
    | anna@sadmutts.com   |       | true      |
    | ernt@mutts.com      |       | false     |
    | admin@shf.se        | true  |           |

  And the following business categories exist
    | name         |
    | Groomer      |
    | Psychologist |
    | Trainer      |

  And the following applications exist:
    | first_name | user_email          | company_number | category_name | state    |
    | Emma       | emma@happymutts.com | 5562252998     | Trainer       | accepted |
    | Ernt       | ernt@mutts.com      | 5569467466     | Groomer       | accepted |
    | Anna       | anna@sadmutts.com   | 2120000142     | Psychologist  | accepted |

Scenario: View all users
  Given I am logged in as "admin@shf.se"
  When I am on the "all users" page
  And I should see "admin@shf.se"
  And I should see "emma@happymutts.com"
  And I should see "anna@sadmutts.com"
  And I should see "ernt@mutts.com"
