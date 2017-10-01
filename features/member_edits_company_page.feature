Feature: As a member
  So that visitors can see if my company offers services they might be interested in
  I need to be able to set a page that displays information about my company

  PT:  https://www.pivotaltracker.com/story/show/133081453

  Background:
    Given the following users exists
      | email               | admin | is_member |
      | emma@happymutts.com |       | true      |
      | admin@shf.se        | true  | true      |

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

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Awesome      |

    And the following applications exist:
      | user_email          | company_number | categories | state    |
      | emma@happymutts.com | 5562252998     | Awesome    | accepted |

  @javascript
  Scenario: Member goes to company page after membership approval, specifes mail address
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

    And I click the second address for company "Happy Mutts"
    And I click on the t("addresses.edit.delete") link
    And I confirm popup
    Then I should see t("addresses.destroy.success")
    And I should see "2" addresses

    And I am Logged out
    And I am on the "landing" page
    And I click on "Happy Mutts"
    And I should see "1" address


  Scenario: Another tries to edit your company page (gets rerouted)
    Given I am logged in as "emma@happymutts.com"
    And I am on the "edit my company" page
    And I fill in the translated form with data:
      | companies.company_name | companies.show.company_number | companies.show.email | companies.website_include_http |
      | Happy Mutts            | 5562252998                    | kicki@gladajyckar.se | http://www.gladajyckar.se      |
    And I click on t("submit")
    And I am Logged out
    And I am logged in as "applicant_2@random.com"
    And I am on the "edit my company" page for "emma@happymutts.com"
    Then I should be on the "landing" page
    And I should see t("errors.not_permitted")


  Scenario: User tries to go do company page (gets rerouted)
    Given I am logged in as "applicant_2@random.com"
    And I am on the "edit my company" page for "emma@happymutts.com"
    Then I should be on the "landing" page
    And I should see t("errors.not_permitted")
