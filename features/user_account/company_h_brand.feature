Feature: Member gets their customized SHF membership card (proof of membership)

  As a member
  I need to view, download, and print my customized SHF membership card
  So that I can show proof of my membership to my customers and potential customers
  And gain the value that comes from being a member of the organization

  Background:
    Given the App Configuration is not mocked and is seeded

    Given the following users exist
      | email         | admin | member | membership_number | first_name | last_name |
      | emma@mutts.se |       | true   | 1001              | Emma       | Edmond    |

    Given the following business categories exist
      | name  | description                     |
      | groom | grooming dogs from head to tail |
      | rehab | physical rehabilitation         |

    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 5562252998     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email    | company_number | categories   | state    |
      | emma@mutts.se | 5562252998     | rehab, groom | accepted |

    Given the date is set to "2017-11-01"

    Given the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.se | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

    Given the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.se | 2017-10-1  | 2017-12-31  | branding_fee | betald | none    | 5562252998     |

    Given I am logged in as "emma@mutts.se"

  @time_adjust
  Scenario: Member downloads proof-of-membership image
    Given I am on the "landing" page for "emma@mutts.se"
    And I should see t("hello", name: 'Emma')
    Then I click on the t("menus.nav.users.your_account") link
    And I should see t("users.show.proof_of_membership")
    And I should see "groom, rehab"
    And I click on the t("users.show.download_image") link
    Then I should get a downloaded image with the filename "proof_of_membership.jpeg"

  @time_adjust
  Scenario: Member views proof-of-membership image
    Given I am on the "landing" page for "emma@mutts.se"
    And I should see t("hello", name: 'Emma')
    Then I click on the t("menus.nav.users.your_account") link
    And I should see t("users.show.proof_of_membership")
    And I should see "groom, rehab"
    And I click on the t("users.show.show_image") link
    And I should see t("users.show.use_this_image_link_html")


  @selenium @time_adjust
  Scenario: Member sees tooltip info about downloading image instead of normal browser context menu
    Given I am on the "user profile" page for "emma@mutts.se"
    When I right click on "#company-h-brand"
    Then I should see t("users.show.download_image")
    And I should see t("users.show.show_image")
    And I should see t("users.show.copy_image_url")
