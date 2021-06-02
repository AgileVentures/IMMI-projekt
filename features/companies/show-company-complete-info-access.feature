Feature: Only show companies with incomplete info to admins and users or members of the company.

  So that visitors and users and members that are not a member of a company
  do not see a company until all of the necessary information for displaying it is "complete,"
  only show companies with incomplete information to admins and those that are part of the company.
  All others should get a 404 message.
  They should not get a 'you are not authorized' message because we don't want to give
  any hints that the company does or does not exist.  This is especially important for bots;
  if they infer that a company (page) does exist, they may try to continue to access it and/or
  continue to try even more malicious things.

  PivotalTracker: https://www.pivotaltracker.com/story/show/177274707


  Background:

    Given the date is set to "2019-06-06"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following kommuns exist:
      | name     |
      | Alingsås |


    Given the following companies exist:
      | name     | company_number | email                               | region    | kommun   | city      | visibility     |
      |          | 5560360793     | hello@incomplete-info-company-1.com | Stockholm | Alingsås | Harplinge | street_address |
      | Company2 | 2120000142     | hello@company-2.com                 | Stockholm | Alingsås | Harplinge | street_address |


    And the following users exist:
      | email                            | admin | membership_status | member |
      | member-1@addr-all-visible-1.com  |       | current_member    | true   |
      | member@company-2.com             |       | current_member    | true   |
      | applicant-6@addr-not-visible.com |       |                   | false  |
      | member-company6@example.com      |       | current_member    | true   |
      | member-2@addr-all-visible-1.com  |       | current_member    | true   |
      | admin@shf.se                     | true  |                   | false  |


    And the following business categories exist
      | name    |
      | Groomer |


    And the following applications exist:
      | user_email                      | company_number | categories | state    |
      | member-1@addr-all-visible-1.com | 5560360793     | Groomer    | accepted |
      | member@company-2.com            | 2120000142     | Groomer    | accepted |
      | member-company6@example.com     | 6914762726     | Groomer    | accepted |

    And the following payments exist
      | user_email                      | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member-1@addr-all-visible-1.com | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |                |
      | member@company-2.com            | 2019-10-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-company6@example.com     | 2019-10-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-2@addr-all-visible-1.com | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |                |
      | member-2@addr-all-visible-1.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | member@company-2.com            | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | member-company6@example.com     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |

    And the following memberships exist:
      | email                           | first_day  | last_day   |
      | member-1@addr-all-visible-1.com | 2019-01-01 | 2019-12-31 |
      | member@company-2.com            | 2019-10-1  | 2019-12-31 |
      | member-company6@example.com     | 2019-10-1  | 2019-12-31 |
      | member-2@addr-all-visible-1.com | 2019-01-01 | 2019-12-31 |

   # --------------------------------------------------------------------------------------------

  Scenario: Visitor cannot see a company with incomplete info; gets a 404 error.
    Given I am Logged out
    When I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should not see "hello@incomplete-info-company-1.com"

    # The actual entity type will be passed in and shown, but it's beyond the current step to fill it in with a nested t("").
    #  As long as the error message is being displayed, it is working as it should.
    And I should see t("activerecord.errors.messages.record_not_found.header", entity_type: '')


  Scenario: User that is not a part of the company  cannot see a company with incomplete info; gets a 404 error.
    Given I am logged in as "applicant-6@addr-not-visible.com"
    When I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should not see "hello@incomplete-info-company-1.com"

    # The actual entity type will be passed in and shown, but it's beyond the current step to fill it in with a nested t("").
    #  As long as the error message is being displayed, it is working as it should.
    And I should see t("activerecord.errors.messages.record_not_found.header", entity_type: '')


  Scenario: Member that is not part of the company cannot see a company with incomplete info; gets a 404 error.
    Given I am logged in as "member-company6@example.com"
    And I am the page for company number "5560360793"
    Then I should not see "5560360793"
    And I should not see "hello@incomplete-info-company-1.com"

    # The actual entity type will be passed in and shown, but it's beyond the current step to fill it in with a nested t("").
    #  As long as the error message is being displayed, it is working as it should.
    And I should see t("activerecord.errors.messages.record_not_found.header", entity_type: '')


  Scenario: Member that is part of the company can see a company with incomplete info.
    Given I am logged in as "member-1@addr-all-visible-1.com"
    When I am the page for company number "5560360793"
    Then I should see t("companies.show.this_info_missing")
    And I should see "Groomer"
    And I should see "hello@incomplete-info-company-1.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"


  Scenario: Admin can see all incomplete companies.
    Given I am logged in as "admin@shf.se"
    When I am the page for company number "5560360793"
    Then I should see t("companies.show.this_info_missing")
    And I should see "Groomer"
    And I should see "hello@incomplete-info-company-1.com"
    And I should see "123123123"
    And I should see "Hundforetagarevägen 1"
    And I should see "310 40"
    And I should see "Harplinge"
    And I should see "http://www.example.com"
