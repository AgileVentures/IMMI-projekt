Feature: Member edits a company attribute

  As a member
  So that visitors can see if my company offers services they might be interested in
  I need to be able to set a page that displays information about my company

  PT:  https://www.pivotaltracker.com/story/show/133081453

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email               | admin | member | agreed_to_membership_guidelines |
      | emma@happymutts.com |       | true   | true                            |
      | member@random.com   |       | true   | true                            |
      | user@random.com     |       |        | true                            |
      | admin@shf.se        | true  | false  |                                 |

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name      |
      | Alingsås  |

    And the following companies exist:
      | name                 | company_number | email                  |
      | Woof Woof            | 5560360793     | emma@happymutts.com    |

    And the following business categories exist
      | name         |
      | Awesome      |

    And the following applications exist:
      | user_email          | company_number | categories | state    |
      | emma@happymutts.com | 5562252998     | Awesome    | accepted |

    And the following payments exist
      | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@happymutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5562252998     |
      | emma@happymutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |


  @selenium @time_adjust @focus
  Scenario: Member goes to company page after membership approval, specifies mail address
    Given the date is set to "2017-10-01"
    Given I am logged in as "emma@happymutts.com"
    And I am on the "edit my company" page for "emma@happymutts.com"
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.email | companies.website_include_http |
      | Happy Mutts            | 5562252998                    | kicki@gladajyckar.se | http://www.gladajyckar.se      |
    And I click on t("submit")
    Then I should see t("companies.update.success")
    Then I click on t("companies.show.add_address")
    And I fill in the translated form with data:
      | activerecord.attributes.address.street | activerecord.attributes.address.post_code | activerecord.attributes.address.city |
      | Ålstensgatan 4                         | 123 45                                    | Bromma                               |
    And I select "Stockholm" in select list t("activerecord.attributes.address.region")
    And I select "Alingsås" in select list t("activerecord.attributes.address.kommun")
    And I click on t("submit")
    Then I should see t("addresses.create.success")
    And I should see "HAPPY MUTTS"
    And I should see "123 45"
    And I should see "Bromma"
    And I should see "Alingsås"
    And I should see "2" addresses

    Then I click on t("companies.show.add_address")
    And I fill in the translated form with data:
      | activerecord.attributes.address.street | activerecord.attributes.address.post_code | activerecord.attributes.address.city |
      | Acksjö Gräsbacken 1                    | 441 94                                    | Alingsås                             |
    And I select "Västerbotten" in select list t("activerecord.attributes.address.region")
    And I select "Alingsås" in select list t("activerecord.attributes.address.kommun")
    And I click on t("submit")
    Then I should see t("addresses.create.success")

    When I select the radio button with label "Hundforetagarevägen 1, 310 40, Harplinge, Ale, Sverige"
    Then I should see the radio button with label "Hundforetagarevägen 1, 310 40, Harplinge, Ale, Sverige" checked
    And I should see the radio button with label "Ålstensgatan 4, 123 45, Bromma, Alingsås, Sverige" unchecked
    And I should see the radio button with label "Acksjö Gräsbacken 1, 441 94, Alingsås, Alingsås, Sverige" unchecked

    When I select the radio button with label "Acksjö Gräsbacken 1, 441 94, Alingsås, Alingsås, Sverige"
    Then I should see the radio button with label "Acksjö Gräsbacken 1, 441 94, Alingsås, Alingsås, Sverige" checked
    And I should see the radio button with label "Hundforetagarevägen 1, 310 40, Harplinge, Ale, Sverige" unchecked
    And I should see the radio button with label "Ålstensgatan 4, 123 45, Bromma, Alingsås, Sverige" unchecked

    When I click the first address for company "Happy Mutts"
    And I select t("address_visibility.none") in select list t("companies.address_visibility")
    And I click on t("submit")
    Then I should see "3" addresses

    When I click the third address for company "Happy Mutts"
    Then I should see t("addresses.edit.cannot_delete_address")
    And I should not see t("'addresses.edit.delete'")

    When I click on the t("companies.view_company") link
    And I click the second address for company "Happy Mutts"
    Then I should not see t("addresses.edit.cannot_delete_address")

    When I click on and accept the t("addresses.edit.delete") link
    Then I should see t("addresses.destroy.success")
    And I should see "2" addresses

    When I am Logged out
    And I am on the "landing" page
    And I click on "Happy Mutts"
    Then I should see "1" address


#    Scenario: Member enters invalid facebook URL



  # Authorization/Access (who can/cannot edit a company page)

  @time_adjust
  Scenario: Another tries to edit your company page (gets rerouted)
    Given the date is set to "2017-10-01"
    Given I am logged in as "emma@happymutts.com"
    And I am on the "edit my company" page
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.email | companies.website_include_http |
      | Happy Mutts            | 5562252998                    | kicki@gladajyckar.se | http://www.gladajyckar.se      |
    And I click on t("submit")
    And I am Logged out
    And I am logged in as "member@random.com"
    And I am on the "edit my company" page for "emma@happymutts.com"
    Then I should be on the "landing" page
    And I should see t("errors.not_permitted")


  Scenario: User tries to go to company page (gets rerouted)
    Given I am logged in as "user@random.com"
    And I am on the "edit my company" page for "emma@happymutts.com"
    Then I should be on the "landing" page
    And I should see t("errors.not_permitted")
