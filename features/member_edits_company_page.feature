Feature: As a member
  So that visitors can see if my company offers services they might be interested in
  I need to be able to set a page that displays information about my company

  PT:  https://www.pivotaltracker.com/story/show/133081453

  Background:
    Given the following users exists
      | email               | admin | member |
      | emma@happymutts.com |       | true   |
      | member@random.com   |       | true   |
      | user@random.com     |       |        |
      | admin@shf.se        | true  | false  |

    Given the following payments exist
      | user_email          | start_date | expire_date | payment_type | status | hips_id |
      | emma@happymutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name      |
      | Alingsås  |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 2120000142     | snarky@snarkybarky.com |
      | Woof Woof            | 5560360793     | emma@happymutts.com    |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Awesome      |

    And the following applications exist:
      | user_email          | company_number | categories | state    |
      | emma@happymutts.com | 5562252998     | Awesome    | accepted |

    And the following payments exist
      | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@happymutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5562252998     |

  @selenium @time_adjust
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

    Then I click the radio button with id "cb_address_3"
    And I should not see the radio button with id "cb_address_3" unchecked
    And I should see the radio button with id "cb_address_4" unchecked
    And I should see the radio button with id "cb_address_5" unchecked

    Then I click the radio button with id "cb_address_5"
    And I should not see the radio button with id "cb_address_5" unchecked
    And I should see the radio button with id "cb_address_3" unchecked
    And I should see the radio button with id "cb_address_4" unchecked

    And I click the first address for company "Happy Mutts"
    And I select t("address_visibility.none") in select list t("companies.address_visibility")
    And I click on t("submit")
    And I should see "3" addresses

    Then I click the third address for company "Happy Mutts"
    And I should see t("addresses.edit.cannot_delete_address")
    And I should not see t("'addresses.edit.delete'")
    And I click on the t("companies.view_company") link

    And I click the second address for company "Happy Mutts"
    And I should not see t("addresses.edit.cannot_delete_address")
    And I click on and accept the t("addresses.edit.delete") link
    Then I should see t("addresses.destroy.success")
    And I should see "2" addresses

    And I am Logged out
    And I am on the "landing" page
    And I click on "Happy Mutts"
    And I should see "1" address

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
