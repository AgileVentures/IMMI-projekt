Feature: Member gets their customized SHF membership card (proof of membership)

  As a member
  I need to view, download, and print my customized SHF membership card
  So that I can show proof of my membership to my customers and potential customers
  And gain the value that comes from being a member of the organization

  Background:
    Given the App Configuration is not mocked and is seeded
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | email                   | admin | member | membership_number | first_name  | last_name |
      | emma@mutts.se           |       | true   | 1001              | Emma        | Edmond    |
      | member-expired@mutts.se |       | false  | 999               | ExpiredLars | Member    |

    Given the following business categories exist
      | name  | description                     |
      | groom | grooming dogs from head to tail |
      | rehab | physical rehabilitation         |

    Given the following applications exist:
      | user_email              | company_number | categories   | state    |
      | emma@mutts.se           | 5562252998     | rehab, groom | accepted |
      | member-expired@mutts.se | 5562252998     | groom        | accepted |

    Given the date is set to "2017-11-01"

    Given the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.se           | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | member-expired@mutts.se | 2016-10-1  | 2016-12-31  | member_fee   | betald | none    |


  @time_adjust
  Scenario: Member downloads proof-of-membership image
    Given I am logged in as "emma@mutts.se"
    And I am on the "landing" page for "emma@mutts.se"
    Then I should see t("hello", name: 'Emma')
    When I click on the t("menus.nav.users.your_account") link
    Then I should see t("users.show_member_images_row_cols.proof_of_membership")
    And I should see "groom, rehab"
    When I click on the t("users.show_member_images_row_cols.download_image") link
    Then I should get a downloaded image with the filename "proof_of_membership.jpg"

  @time_adjust
  Scenario: Member views proof-of-membership html image
    Given I am logged in as "emma@mutts.se"
    And I am on the "proof of membership html image" page for "emma@mutts.se"
    Then I should see t("users.proof_of_membership.proof_title")
    And I should see t("users.proof_of_membership.member_number")
    And I should see "1001"
    And I should see "groom, rehab"
    And I should see t("users.proof_of_membership.issued_by")
    And I should see t("users.proof_of_membership.valid_thru", expire_date: )
    And I should see t("users.proof_of_membership.footer")

  @selenium
  Scenario: Expired Membership says 'Expired'
    Given I am logged in as "member-expired@mutts.se"
    And I am on the "proof of membership html image" page for "member-expired@mutts.se"
    Then I should see t("users.proof_of_membership.proof_title")
    And I should not see t("users.proof_of_membership.member_number")
    And I should not see "999"
    And I should not see "groom, rehab"
    And I should not see t("users.proof_of_membership.issued_by")
    And I should not see t("users.proof_of_membership.valid_thru", expire_date: )
    And I should see t("users.proof_of_membership.expired")
    And I should see t("users.proof_of_membership.footer")

  @selenium @time_adjust
  Scenario: Member sees custom context menu instead of normal browser context menu
    Given I am logged in as "emma@mutts.se"
    And I am on the "user account" page for "emma@mutts.se"
    When I right click on "#proof-of-membership"
    Then I should see t("users.show_member_images_row_cols.download_image")
    And I should see t("users.show_member_images_row_cols.show_image")
    And I should see t("users.show_member_images_row_cols.copy_image_url")
