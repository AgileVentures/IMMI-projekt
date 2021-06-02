Feature:  Member home (account) page

  Show account (details) information to a member

  As a member
  So that I know what information SHF has about me
  And so I know what my membership status is and term dates are,
  Show me my account page (which is my home/landing page)

  PT:  https://www.pivotaltracker.com/story/show/140358959

  Proof of Membership and Company H-Branding Information: see separate features
  features/user_account/company_h_brand.feature
  features/user_account/proof_of_membership.feature

  Background:

    Given the date is set to "2018-01-01"
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists


    Given the following users exist:
      | email                   | admin | membership_status | membership_number | member | first_name | last_name |
      | emma-member@example.com |       | current_member    | 1001              | true   | Emma       | IsAMember |
      | admin@shf.se            | true  |                   |                   |        |            |           |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                   |
      | emma-member@example.com |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name    | company_number | email            | region    |
      | Bowsers | 2120000142     | bark@bowsers.com | Stockholm |


    And the following business categories exist
      | name     | description   | subcategories          |
      | Training | training      |                        |
      | Grooming | grooming dogs | light trim, custom cut |


    And the following applications exist:
      | user_email              | contact_email           | company_number | state    | categories         |
      | emma-member@example.com | emma-member@bowsers.com | 2120000142     | accepted | Grooming, Training |


    And the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | branding_fee | betald | none    | 2120000142     |

    And the following memberships exist
      | email                   | first_day | last_day   | notes |
      | emma-member@example.com | 2018-01-1 | 2018-12-31 |       |

    Given I am logged in as "emma-member@example.com"
    And I am on the "user account" page for "emma-member@example.com"
    Then I am a current member

  # ---------------------------------------------------------------------------------------------


  Scenario: Member sees greeting and their full name and login email
    Then I should see t("users.show.hello")
    And I should see "Emma IsAMember"
    And I should see t("users.show_login_email_row_cols.email")
    And I should see "emma-member@example.com"


  Scenario: Sections for membership status, application, business categories, proof of membership, and h-mark are shown
    Then I should see t("users.show_for_member.membership_number")
    And I should see t("activerecord.attributes.membership.status.current_member")
    And I should see t("users.show_for_member.membership_number")
    And I should see t("application")
    And I should see t("activerecord.models.business_category.other")
    And I should see t("users.show_member_images_row_cols.proof_of_membership")
    And I should see t("users.show_member_images_row_cols.company_h_brand", company: 'Bowsers')


  # ======================
  # Membership Information

  Scenario: Member sees their membership number, status, and date the membership term is paid through
    Then I should see t("users.show.membership_number")
    And I should see "1001"
    And I should see "Status"
    And I should see t("users.show.is_a_member")
    And I should see t("users.show.membership_term_last_day")
    And the user is paid through "2018-12-31"
#   TODO And user membership last day is "2018-12-31"


  # =======================
  # Application information

  Scenario: Application section shows the status (accepted),and company(-ies) on the application
    Then I should see t("activerecord.attributes.shf_application.contact_email")
    And I should see t("activerecord.attributes.shf_application.state")
    And I should see t("activerecord.models.company.one")
    And I should see t("shf_applications.state.accepted")
    And I should see "Bowsers"
    And I should see "2120000142"



  # ===================
  # Business Categories

  Scenario: All of the business categories are shown
    Then I should see t("activerecord.models.business_category.one")
    And I should see t("activerecord.models.business_category.other")
    Then I should see "Training"
    And I should see "Grooming"


  # ==================================================
  # Proof of Membership and Company H-Branding Images: see separate features
