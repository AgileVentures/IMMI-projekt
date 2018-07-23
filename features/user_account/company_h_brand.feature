Feature: As an user I want to be able to view and download my company h-brand
  So that I can use it in multiple ways to confirm my association with the organization
  And also show my business services that have been certified by the organization

  Background:
    Given the following users exist
      | email         | admin | member | membership_number | first_name | last_name |
      | emma@mutts.se |       | true   | 1001              | Emma       | Edmond    |

    Given the following business categories exist
      | name  | description                     |
      | groom | grooming dogs from head to tail |
      | rehab | physical rehabilitation         |

    Given the following companies exist:
      | name     | company_number | email          | region    | kommun   | visibility     |
      | EmmaCmpy | 5562252998     | cmpy1@mail.com | Stockholm | Alingsås | street_address |

    Given the following applications exist:
      | user_email    | company_number | categories   | state    |
      | emma@mutts.se | 5562252998     | rehab, groom | accepted |

    Given the date is set to "2017-11-01"

    Given the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.se | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | emma@mutts.se | 2017-10-1  | 2017-12-31  | branding_fee | betald | none    | 5562252998     |

  @time_adjust
  Scenario: Member downloads company-h-brand image
    Given I am logged in as "emma@mutts.se"
    And I am on the "landing" page for "emma@mutts.se"
    And I should see t("hello", name: 'Emma')
    Then I click on the t("menus.nav.users.your_account") link
    And I should see t("users.show.company_h_brand", company: 'EmmaCmpy')
    And I should see "groom, rehab"
    And I click on the second t("users.show.download_image") link
    Then I should get a downloaded image with the filename "company_h_brand.jpeg"

  @time_adjust
  Scenario: Member views company-h-brand image
    Given I am logged in as "emma@mutts.se"
    And I am on the "landing" page for "emma@mutts.se"
    And I should see t("hello", name: 'Emma')
    Then I click on the t("menus.nav.users.your_account") link
    And I should see t("users.show.company_h_brand", company: 'EmmaCmpy')
    And I should see "groom, rehab"
    And I click on the second t("users.show.show_image") link
    And I should see t("users.show.use_this_image_link_html")
