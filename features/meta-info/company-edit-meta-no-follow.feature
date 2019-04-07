Feature: Edit a company page has meta tags nofollow and noindex set

  Background:

    Given the date is set to "2018-07-01"

    Given the following users exist
      | email          | admin | member |
      | emma@mutts.com |       | true   |
      | admin@shf.se   | true  | false  |

    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |


    Given the following applications exist:
      | user_email     | company_number | category_name | state    |
      | emma@mutts.com | 2120000142     | rehab         | accepted |


    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2017-10-1  | 2018-09-30  | branding_fee | betald | none    | 2120000142     |
      | emma@mutts.com | 2017-10-1  | 2018-09-30  | member_fee   | betald | none    |                |


  Scenario: The edit company page has meta name = robots set to noindex,nofollow
    Given I am logged in as "emma@mutts.com"
    And I am on the edit company page for "2120000142"
    Then I should see t("companies.edit.title", company_name: "HappyMutts")

    And the page title should be "Sveriges Hundföretagare"
    And the page head should not include a link tag with rel = "image_src" and href = "http://www.example.com/assets/Sveriges_hundforetagare_banner_sajt.jpg"

    And the page head should include meta "name" "robots" with content = "noindex, nofollow"

    And the page head should not include meta "property" "og:title"
    And the page head should not include meta "property" "og:description"
    And the page head should not include meta "property" "og:type"
    And the page head should not include meta "property" "og:url"
    And the page head should not include meta "property" "og:locale"
    And the page head should not include meta "property" "og:image"
    And the page head should not include meta "property" "og:image:type"
    And the page head should not include meta "property" "og:image:width"
    And the page head should not include meta "property" "og:image:height"

    And the page head should not include meta "name" "twitter:card"
