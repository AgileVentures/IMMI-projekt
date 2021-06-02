Feature: Edit the social media urls (links) for a company

  Background:

    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email            | admin | membership_status | member |
      | member@mutts.com |       | current_member    | true   |
      | admin@shf.se     | true  |                   | true   |

    And the following companies exist:
      | name    | company_number | email              |
      | Bowsers | 2120000142     | bowwow@bowsers.com |

    And the following applications exist:
      | user_email       | company_number | state    |
      | member@mutts.com | 2120000142     | accepted |

    Given the following payments exist
      | user_email       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member@mutts.com | 2019-1-1   | 2019-12-31  | member_fee   | betald | none    |                |
      | member@mutts.com | 2019-1-1   | 2019-12-31  | branding_fee | betald | none    | 2120000142     |

    And the following memberships exist:
      | email            | first_day | last_day   |
      | member@mutts.com | 2019-1-1  | 2019-12-31 |

    Given the date is set to "2019-10-10"

  # -----------------------------------------------------------------------------------------------

  Scenario: All social media urls are changed successfully
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"
    Then I should see t("companies.form.facebook_url")
    And I should see t("companies.form.instagram_url")
    And I should see t("companies.form.youtube_url")
    When I fill in t("companies.form.facebook_url") with "https://facebook.com/example"
    And I fill in t("companies.form.youtube_url") with "https://youtube.com/example"
    And I fill in t("companies.form.instagram_url") with "https://instagram.com/example"
    And I click on t("submit")
    Then I should see t("companies.update.success")
    And I should see an icon with CSS class "fa-facebook" that is linked to "https://facebook.com/example"
    And I should see an icon with CSS class "fa-youtube" that is linked to "https://youtube.com/example"
    And I should see an icon with CSS class "fa-instagram" that is linked to "https://instagram.com/example"


  # -------------------------------------------------------------------
  # Javascript validation error message should show for invalid entries

  @selenium
  Scenario: Error message shows if Facebook url is invalid
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"

    # Invalid Protocol
    When I fill in t("companies.form.facebook_url") with "http://facebook.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.instagram_url") with "https://instagram.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "https://facebook.com")

    # Clear the error message by entering a valid url
    When I fill in t("companies.form.facebook_url") with "https://facebook.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.instagram_url") with "https://instagram.com/example"
    Then I should not see t("companies.form.bad_url_must_start_with", url_start: "https://facebook.com")

    # Invalid host name
    When I fill in t("companies.form.facebook_url") with "https://blorf.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.instagram_url") with "https://instagram.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "https://facebook.com")


  @selenium
  Scenario: Error message shows if Instagram url is invalid
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"

    # Invalid Protocol
    When I fill in t("companies.form.instagram_url") with "http://instagram.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.facebook_url") with "https://facebook.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "https://instagram.com")

    # Clear the error message by entering a valid url
    When I fill in t("companies.form.instagram_url") with "https://instagram.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.facebook_url") with "https://facebook.com/example"
    Then I should not see t("companies.form.bad_url_must_start_with", url_start: "https://instagram.com")

    # Invalid host name
    When I fill in t("companies.form.instagram_url") with "https://blorf.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.facebook_url") with "https://facebook.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "https://instagram.com")


  @selenium
  Scenario: Error message shows if YouTube url is invalid
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"

    # Invalid Protocol
    When I fill in t("companies.form.youtube_url") with "http://youtube.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.facebook_url") with "https://facebook.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "https://youtube.com")

    # Clear the error message by entering a valid url
    When I fill in t("companies.form.youtube_url") with "https://youtube.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.facebook_url") with "https://facebook.com/example"
    Then I should not see t("companies.form.bad_url_must_start_with", url_start: "https://youtube.com")

    # Invalid host name
    When I fill in t("companies.form.youtube_url") with "https://blorf.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.facebook_url") with "https://facebook.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "https://youtube.com")
