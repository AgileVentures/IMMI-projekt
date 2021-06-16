Feature: Admin edits application configuration
  As an admin
  I want to be able to edit application configuration
  including images for the site meta image, chair signature, SHF logo images, and company h-brand;
  site name, and meta information: title, keywords, and description.


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email             | password | admin | member    | first_name | last_name |
      | admin@random.com  | password | true  | false     | emma       | admin     |

    And the App Configuration is not mocked and is seeded

    And I am logged in as "admin@random.com"
    And I am on the "admin edit app configuration" page


  Scenario: Admin uploads SHF logo and chairperson signature
    Then I should see t("admin_only.app_configuration.edit.title")
    And I choose an application configuration "admin_only_app_configuration[chair_signature]" file named "chair_signature.png" to upload
    And I choose an application configuration "admin_only_app_configuration[shf_logo]" file named "shf_logo.png" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")

  Scenario: Admin uploads images for company h-brand
    Then I should see t("admin_only.app_configuration.edit.title")
    And I choose an application configuration "admin_only_app_configuration[h_brand_logo]" file named "h_brand_logo.png" to upload
    And I choose an application configuration "admin_only_app_configuration[sweden_dog_trainers]" file named "sweden_dog_trainers.png" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")

  Scenario: Admin edits app configuration and tries to upload non-image file
    Then I should see t("admin_only.app_configuration.edit.title")
    And I choose an application configuration "admin_only_app_configuration[shf_logo]" file named "specifications.txt" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.error")


  Scenario: Admin changes Facebook Application Id
    Then I should see t("admin_only.app_configuration.edit.title")
    And I fill in t("admin_only.app_configuration.edit.facebook_app_id") with "555555"
    And I click on the t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")
    And I should see "555555"


  Scenario: Admin changes the site title, name, description, and keywords and the meta info is updated
    Given I am logged out
    And I am on the "all companies" page
    And the page title should be "Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare"
    And the page head should include meta "name" "description" with content = "Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera."
    And the page head should include meta "name" "keywords" with content = "hund, hundägare, hundinstruktör, hundentreprenör, Sveriges Hundföretagare, svenskt hundföretag, etisk, H-märkt, hundkurs"
    And the page head should include meta "property" "og:title" with content = "Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare"
    And the page head should include meta "property" "og:description" with content = "Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera."

    And I am logged in as "admin@random.com"
    And I am on the "admin edit app configuration" page
    Then I should see t("admin_only.app_configuration.edit.title")
    And I fill in t("admin_only.app_configuration.edit.site_name") with "this is the new site name"
    And I fill in t("admin_only.app_configuration.edit.site_meta_title") with "this is the new site title"
    And I fill in t("admin_only.app_configuration.edit.site_meta_description") with "this is the new site description"
    And I fill in t("admin_only.app_configuration.edit.site_meta_keywords") with "these are the new site keywords"
    And I click on the t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")
    And I should see "this is the new site name"
    And I should see "this is the new site title"
    And I should see "this is the new site description"
    And I should see "these are the new site keywords"
    And I am logged out
    And I am on the "all companies" page
    And the page title should be "this is the new site title"
    And the page head should include meta "name" "description" with content = "this is the new site description"
    And the page head should include meta "name" "keywords" with content = "these are the new site keywords"
    And the page head should include meta "property" "og:title" with content = "this is the new site title | this is the new site name"
    And the page head should include meta "property" "og:description" with content = "this is the new site description"


  Scenario: Admin changes the og type and twitter card type and the meta info is updated
    Given I am logged out
    And I am on the "all companies" page
    And the page head should include meta "property" "og:type" with content = "website"
    And the page head should include meta "name" "twitter:card" with content = "summary"

    And I am logged in as "admin@random.com"
    And I am on the "admin edit app configuration" page
    Then I should see t("admin_only.app_configuration.edit.title")
    And I fill in t("admin_only.app_configuration.edit.og_type") with "new og type"
    And I fill in t("admin_only.app_configuration.edit.twitter_card_type") with "new twitter card type"
    And I click on the t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")
    And I should see "new og type"
    And I should see "new twitter card type"
    And I am logged out
    And I am on the "all companies" page
    And the page head should include meta "property" "og:type" with content = "new og type"
    And the page head should include meta "name" "twitter:card" with content = "new twitter card type"


  Scenario: Admin changes the site meta image and it is available as a public url
    Given I am logged out
    And I am on the "all companies" page
    And the page head should include a link tag with rel = "image_src" and href matching "Sveriges_hundforetagare_banner_sajt.jpg"
    And the page head should include meta "property" "og:image" with content matching "Sveriges_hundforetagare_banner_sajt.jpg"
    And the page head should include meta "property" "og:image:type" with content = "image/jpeg"
    And the page head should include meta "property" "og:image:width" with content = "1245"
    And the page head should include meta "property" "og:image:height" with content = "620"

    And I am logged in as "admin@random.com"
    And I am on the "admin edit app configuration" page
    Then I should see t("admin_only.app_configuration.edit.title")
    And I choose an application configuration "admin_only_app_configuration[site_meta_image]" file named "image.png" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")
    And the "site_meta_image" attachment is available via a public url


    Scenario: Problem with editting AppConfig, goes back to edit page (SAD PATH)
      Given I am logged in as "admin@random.com"
      And I am on the "admin edit app configuration" page
      And I fill in t("admin_only.app_configuration.edit.site_name") with ""
      And I click on t("submit") button
      Then I should see t("admin_only.app_configuration.update.error")
      And I should see t("admin_only.app_configuration.edit.title")
