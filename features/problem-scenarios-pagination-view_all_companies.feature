Feature: Visitor sees all companies

  2020-09-10:
  These scenarios have problems: they often fail on  (CI) Semaphore.
  Problems seem to be the timing of the DOM refresh/changes and the
  different processes  used (e.g. capybara, rails).

  We know these scenarios work in real life, but we still need to have
  these scenarios working so that we are sure that they continue to
  work and so that any other changes do not cause problems with them.


  As a visitor,
  so that I can find companies that can offer me services,
  I want to see all companies

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |
      | Uppsala      |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |
      | Alvesta  |
      | Aneby    |

    And the following business categories exist
      | name    |
      | Groomer |

    Given the following companies exist:
      | name      | company_number | email           | region       | kommun   |
      | Company29 | 5872150379     | cmpy29@mail.com | Stockholm    | Alingsås |
      | Company28 | 8728875504     | cmpy28@mail.com | Stockholm    | Alingsås |
      | Company27 | 9475077674     | cmpy27@mail.com | Stockholm    | Alingsås |
      | Company26 | 9360289459     | cmpy26@mail.com | Stockholm    | Alingsås |
      | Company25 | 9267816362     | cmpy25@mail.com | Stockholm    | Alingsås |
      | Company24 | 9243957975     | cmpy24@mail.com | Stockholm    | Alingsås |
      | Company23 | 9074668568     | cmpy23@mail.com | Stockholm    | Alingsås |
      | Company22 | 8909248752     | cmpy22@mail.com | Stockholm    | Alingsås |
      | Company21 | 5569767808     | cmpy21@mail.com | Stockholm    | Alingsås |
      | Company20 | 8822107739     | cmpy20@mail.com | Stockholm    | Alingsås |
      | Company19 | 8764985894     | cmpy19@mail.com | Stockholm    | Alingsås |
      | Company18 | 8616006592     | cmpy18@mail.com | Stockholm    | Alingsås |
      | Company17 | 8589182768     | cmpy17@mail.com | Stockholm    | Alingsås |
      | Company16 | 8423893877     | cmpy16@mail.com | Stockholm    | Alingsås |
      | Company15 | 8394317054     | cmpy15@mail.com | Stockholm    | Alingsås |
      | Company14 | 8356502446     | cmpy14@mail.com | Stockholm    | Alingsås |
      | Company13 | 8028973322     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company12 | 4268582063     | cmpy12@mail.com | Stockholm    | Alingsås |
      | Company11 | 2965790286     | cmpy11@mail.com | Stockholm    | Alingsås |
      | Company10 | 3609340140     | cmpy10@mail.com | Stockholm    | Alingsås |
      | Company09 | 6112107039     | cmpy9@mail.com  | Stockholm    | Alingsås |
      | Company08 | 7736362901     | cmpy8@mail.com  | Stockholm    | Alingsås |
      | Company07 | 7661057765     | cmpy7@mail.com  | Stockholm    | Alingsås |
      | Company06 | 6914762726     | cmpy6@mail.com  | Stockholm    | Alingsås |
      | Company05 | 8025085252     | cmpy5@mail.com  | Stockholm    | Alingsås |
      | Company04 | 6222279082     | cmpy4@mail.com  | Stockholm    | Alingsås |
      | Company03 | 6613265393     | cmpy3@mail.com  | Stockholm    | Alingsås |
      | Company02 | 2120000142     | cmpy2@mail.com  | Västerbotten | Bromölla |
      | Company01 | 5560360793     | cmpy1@mail.com  | Stockholm    | Alingsås |


    And the following company addresses exist:
      | company_name | region     | kommun  | city    |
      | Company02    | Norrbotten | Alvesta | Årsta   |
      | Company02    | Uppsala    | Aneby   | Kolbäck |

    And the following users exist:
      | email         | admin | member | agreed_to_membership_guidelines |
      | u1@mutts.com  |       | true   | true                            |
      | u2@mutts.com  |       | true   | true                            |
      | u3@mutts.com  |       | true   | true                            |
      | u4@mutts.com  |       | true   | true                            |
      | u5@mutts.com  |       | true   | true                            |
      | u6@mutts.com  |       | true   | true                            |
      | u7@mutts.com  |       | true   | true                            |
      | u8@mutts.com  |       | true   | true                            |
      | u9@mutts.com  |       | true   | true                            |
      | u10@mutts.com |       | true   | true                            |
      | u11@mutts.com |       | true   | true                            |
      | u12@mutts.com |       | true   | true                            |
      | u13@mutts.com |       | true   | true                            |
      | u14@mutts.com |       | true   | true                            |
      | u15@mutts.com |       | true   | true                            |
      | u16@mutts.com |       | true   | true                            |
      | u17@mutts.com |       | true   | true                            |
      | u18@mutts.com |       | true   | true                            |
      | u19@mutts.com |       | true   | true                            |
      | u20@mutts.com |       | true   | true                            |
      | u21@mutts.com |       | true   | true                            |
      | u22@mutts.com |       | true   | true                            |
      | u23@mutts.com |       | true   | true                            |
      | u24@mutts.com |       | true   | true                            |
      | u25@mutts.com |       | true   | true                            |
      | u26@mutts.com |       | true   | true                            |
      | u27@mutts.com |       | true   | true                            |
      | u29@mutts.com |       | true   | true                            |
      | b@mutts.com   |       | false  | true                            |
      | admin@shf.se  | true  |        |                                 |

    And the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id | company_name |
      | u1@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company01    |
      | u1@mutts.com  | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |              |
      | u2@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company02    |
      | u3@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company03    |
      | u4@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company04    |
      | u5@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company05    |
      | u6@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company06    |
      | u7@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company07    |
      | u8@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company08    |
      | u9@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company09    |
      | u10@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company10    |
      | u11@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company11    |
      | u12@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company12    |
      | u13@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company13    |
      | u14@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company14    |
      | u15@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company15    |
      | u16@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company16    |
      | u17@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company17    |
      | u18@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company18    |
      | u19@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company19    |
      | u20@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company20    |
      | u21@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company21    |
      | u22@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company22    |
      | u23@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company23    |
      | u24@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company24    |
      | u25@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company25    |
      | u26@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company26    |
      | u27@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company27    |
      | u29@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company28    |

    And the following applications exist:
      | user_email    | company_name | state    | categories |
      | u1@mutts.com  | Company01    | accepted | Groomer    |
      | u2@mutts.com  | Company02    | accepted | Groomer    |
      | u3@mutts.com  | Company03    | accepted | Groomer    |
      | u4@mutts.com  | Company04    | accepted | Groomer    |
      | u5@mutts.com  | Company05    | accepted | Groomer    |
      | u6@mutts.com  | Company06    | accepted | Groomer    |
      | u7@mutts.com  | Company07    | accepted | Groomer    |
      | u8@mutts.com  | Company08    | accepted | Groomer    |
      | u9@mutts.com  | Company09    | accepted | Groomer    |
      | u10@mutts.com | Company10    | accepted | Groomer    |
      | u11@mutts.com | Company11    | accepted | Groomer    |
      | u12@mutts.com | Company12    | accepted | Groomer    |
      | u13@mutts.com | Company13    | accepted | Groomer    |
      | u14@mutts.com | Company14    | accepted | Groomer    |
      | u15@mutts.com | Company15    | accepted | Groomer    |
      | u16@mutts.com | Company16    | accepted | Groomer    |
      | u17@mutts.com | Company17    | accepted | Groomer    |
      | u18@mutts.com | Company18    | accepted | Groomer    |
      | u19@mutts.com | Company19    | accepted | Groomer    |
      | u20@mutts.com | Company20    | accepted | Groomer    |
      | u21@mutts.com | Company21    | accepted | Groomer    |
      | u22@mutts.com | Company22    | accepted | Groomer    |
      | u23@mutts.com | Company23    | accepted | Groomer    |
      | u24@mutts.com | Company24    | accepted | Groomer    |
      | u25@mutts.com | Company25    | accepted | Groomer    |
      | u26@mutts.com | Company26    | accepted | Groomer    |
      | u27@mutts.com | Company27    | accepted | Groomer    |
      | b@mutts.com   | Company28    | accepted | Groomer    |
      | u29@mutts.com | Company29    | accepted | Groomer    |


  # Why does pagination for companies intermittently fail on CI Semaphore,
  #  problems, but pagination for membership applications does not?
  #  view_shf_applications-pagination.feature (and search for pagination in
  #  other .feature files.
  @selenium @time_adjust @skip_ci_test
  Scenario: Pagination
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    And I hide the companies search form
    # Ensure the list is sorted by name so we will see Company02
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company02" in the list of companies
    And I should not see "2120000142" in the list of companies
    And I should see "Company01" in the list of companies
    And I should not see "5560360793" in the list of companies
    And I should see "Company10" in the list of companies
    And I should not see "3609340140" in the list of companies
    And I should not see "Company11" in the list of companies
    Then I click on t("will_paginate.next_label") link
    And I should see "Company11" in the list of companies
    And I should not see "Company10" in the list of companies


  @selenium @time_adjust @skip_ci_test
  Scenario: Pagination: Set number of items per page
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    And I hide the companies search form
    And "items_count" should have "10" selected
    And I should see "10" companies
    # Ensure the list is sorted by name so we will see Company02
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company10" in the list of companies
    And I should not see "Company11" in the list of companies
    And I should not see "Company26" in the list of companies
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "25" companies
    And "items_count" should have "25" selected
    And I should see "Company01" in the list of companies
    And I should see "Company02" in the list of companies
    And I should see "Company11" in the list of companies
    And I should see "Company12" in the list of companies
    And I should see "Company24" in the list of companies
    And I should see "Company25" in the list of companies
    And I should not see "Company26" in the list of companies
    And I should not see "Company27" in the list of companies
