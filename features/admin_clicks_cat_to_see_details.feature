Feature: Link categories to categories show for an Admin
  As an admin
  In order to see every company that is using the business category
  I need to see all the companies using the business category when I click on the category

  PT: https://www.pivotaltracker.com/n/projects/1904891/stories/164983459

  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name      |
      | Alingsås  |
      | Bromölla  |

    Given the following companies exist:
      | name     | company_number | email          | region       | kommun   | city      | visibility     |
      | Groomer1 | 5560360793     | cmpy1@mail.com | Stockholm    | Alingsås | Harplinge | street_address |
      | kingGroomer | 2120000142     | cmpy2@mail.com | Västerbotten | Bromölla | Harplinge | street_address |
      | GroomerNext | 6613265393     | cmpy3@mail.com | Stockholm    | Alingsås | Harplinge | post_code      |
      | Company4 | 6222279082     | cmpy4@mail.com | Stockholm    | Alingsås | Harplinge | city           |
      | Company5 | 8025085252     | cmpy5@mail.com | Stockholm    | Alingsås | Harplinge | kommun         |
      | PsycGroomerCo | 6914762726     | cmpy6@mail.com | Stockholm    | Alingsås | Harplinge | none           |
      | Company7 | 7661057765     | cmpy7@mail.com | Stockholm    | Alingsås | Harplinge | street_address |
      | stockholmCo | 7736362901     | cmpy8@mail.com | Stockholm    | Alingsås | Harplinge | street_address |

    And the following users exists
      | email           | admin | member |
      | user1@mutts.com |       | true   |
      | user2@mutts.com |       | true   |
      | user3@mutts.com |       | true   |
      | user4@mutts.com |       | true   |
      | user5@mutts.com |       | true   |
      | admin@shf.se    | true  | false  |

    Given the following payments exist
      | user_email      | start_date | expire_date | payment_type | status | hips_id |
      | user2@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | user3@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |


    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Rehab        |
      | Walker       |
      | JustForFun   |

    And the following applications exist:
      | user_email      | company_number | categories              | state    |
      | user1@mutts.com | 5560360793     | Groomer, JustForFun     | accepted |
      | user2@mutts.com | 2120000142     | Groomer, Trainer, Rehab | accepted |
      | user3@mutts.com | 6914762726     | Psychologist, Groomer   | accepted |
      | user4@mutts.com | 6613265393     | Groomer                 | accepted |
      | user5@mutts.com | 2120000142     | Psychologist            | accepted |

    And the following payments exist
      | user_email   | start_date | expire_date | payment_type | status | hips_id | company_number |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6613265393     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6222279082     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8025085252     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7661057765     |
      | admin@shf.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7736362901     |

  @selenium
  Scenario: Show company details to admin
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "6914762726"
    Then I should see "Groomer"
    And I should see "Psychologist"
    When I click on "Groomer"
    Then I should see "Groomer"
    And I should see "PsycGroomerCo"
    And I should see "GroomerNext"
    And I should see "kingGroomer"
    And I should see "Groomer1"
    And I should not see "stockholmCo"
    And I should not see "Company7"
    And I should not see "Company4"
    And I should not see "Company5"

  @selenium
  Scenario: Not display company categories as links to a member
    Given I am logged in as "user1@mutts.com"
    And I am the page for company number "6914762726"
    Then I should not see "Groomer" link

  @selenium
  Scenario: Not display company categories as links to a visitor
    Given I am logged out
    And I am the page for company number "6914762726"
    Then I should not see "Groomer" link

