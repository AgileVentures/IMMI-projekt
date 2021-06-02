Feature: All companies are geocoded before being shown on the view all companies page

  As a visitor,
  so all companies are mapped when I look at the list of them,
  geocode any companies that aren't yet geocoded before everything is displayed,
  unless a company address visibility is set to 'none'

  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |

    Given the following companies exist:
      | name                 | company_number | email                  | region       | kommun   | visibility     |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm    | Alingsås | street_address |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    | Västerbotten | Bromölla | street_address |
      | CompanyNotVisible    | 5569467466     | company@notvisible.com | Stockholm    | Alingsås | none           |

    Given the Membership Ethical Guidelines Master Checklist exists

    And the following users exist:
      | email               | admin | membership_status | member | agreed_to_membership_guidelines |
      | emma@happymutts.com |       | current_member    | true   | true                            |
      | a@happymutts.com    |       | current_member    | true   | true                            |
      | me@notvisible.com   |       | current_member    | true   | true                            |
      | admin@shf.se        | true  |                   |        |                                 |

    And the following business categories exist
      | name    |
      | Groomer |
      | Trainer |

    And the following applications exist:
      | user_email          | company_number | categories | state    |
      | emma@happymutts.com | 5560360793     | Groomer    | accepted |
      | a@happymutts.com    | 2120000142     | Trainer    | accepted |
      | me@notvisible.com   | 5569467466     | Trainer    | accepted |

    And the following payments exist
      | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@happymutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | emma@happymutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | a@happymutts.com    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | a@happymutts.com    | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | me@notvisible.com   | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5569467466     |
      | me@notvisible.com   | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |

    And the following memberships exist:
      | email               | first_day  | last_day   |
      | emma@happymutts.com | 2017-01-01 | 2017-12-31 |
      | a@happymutts.com    | 2017-01-01 | 2017-12-31 |
      | me@notvisible.com   | 2017-01-01 | 2017-12-31 |


    # -----------------------------------------------------------------------------------------------

  @time_adjust
  Scenario: A company that isn't geocoded is geocoded before all are viewed
    Given the date is set to "2017-10-01"
    Given all addresses for the company named "No More Snarky Barky" are not geocoded
    And all addresses for the company named "Bowsers" are not geocoded
    And all addresses for the company named "CompanyNotVisible" are not geocoded
    And I am Logged out
    When I am on the "landing" page
    Then all addresses for the company named "No More Snarky Barky" should be geocoded
    And all addresses for the company named "Bowsers" should be geocoded
    And all addresses for the company named "CompanyNotVisible" should not be geocoded
    And I should see "No More Snarky Barky"
    And I should see "Bowsers"
    And I should see "CompanyNotVisible"
