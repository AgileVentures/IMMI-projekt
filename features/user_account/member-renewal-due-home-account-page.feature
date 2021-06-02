Feature:  Member home (account) page when renewal is due or close to it

  Show that a renewal is due or will be due soon
  and show the steps required to renew (e.g. payment and any other requirements).

  As a member
  So that I know that I need to renew and what I need to do for renewal
  Show the information and all steps required for renewal.

  PT:  https://www.pivotaltracker.com/story/show/140358959

  Background:

    Given the date is set to "2018-06-06"
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists


    Given the following users exist:
      | email                                  | admin | membership_number | membership_status | member | first_name   | last_name                |
      | member-all-reqs-met@example.com        |       | 101               | current_member    | true   | Member       | All-Requirements-met     |
      | member-no-docs-uploaded@example.com    |       | 102               | current_member    | true   | Member       | NoDocsUploaded           |
      | member-no-guidelines@example.com       |       | 103               | current_member    | true   | Member       | HasNotAgreedToGuidelines |
      | member-lapsed-all-reqs-met@example.com |       | 201               | in_grace_period   | true   | LapsedMember | All-Requirements-met     |
      | admin@shf.se                           | true  |                   |                   |        |              |                          |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                                  |
      | member-all-reqs-met@example.com        |
      | member-no-docs-uploaded@example.com    |
      | member-lapsed-all-reqs-met@example.com |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name    | company_number | email            | region    |
      | Bowsers | 2120000142     | bark@bowsers.com | Stockholm |


    And the following business categories exist
      | name     | description   |
      | Grooming | grooming dogs |


    And the following applications exist:
      | user_email                             | contact_email                    | company_number | state    | categories |
      | member-no-docs-uploaded@example.com    | lars-member@happymutts.com       | 2120000142     | accepted | Grooming   |
      | member-all-reqs-met@example.com        | emma-member@bowsers.com          | 2120000142     | accepted | Grooming   |
      | member-no-guidelines@example.com       | member-no-guidelines@bowsers.com | 2120000142     | accepted | Grooming   |
      | member-lapsed-all-reqs-met@example.com | lapsed-member@bowsers.com        | 2120000142     | accepted | Grooming   |


    And the following payments exist
      | user_email                             | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member-all-reqs-met@example.com        | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | member-all-reqs-met@example.com        | 2018-01-1  | 2018-12-31  | branding_fee | betald | none    | 2120000142     |
      | member-no-docs-uploaded@example.com    | 2018-01-01 | 2018-12-31  | member_fee   | betald | none    |                |
      | member-no-guidelines@example.com       | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | member-lapsed-all-reqs-met@example.com | 2017-05-01 | 2018-4-3    | member_fee   | betald | none    |                |


    And the following memberships exist
      | email                                  | membership_number | first_day | last_day   | notes |
      | member-all-reqs-met@example.com        | 101               | 2018-01-1 | 2018-12-31 |       |
      | member-no-docs-uploaded@example.com    | 102               | 2018-01-1 | 2018-12-31 |       |
      | member-no-guidelines@example.com       | 103               | 2018-01-1 | 2018-12-31 |       |
      | member-lapsed-all-reqs-met@example.com | 201               | 2017-05-1 | 2018-4-30  |       |


    And these files have been uploaded:
      | user_email                             | file name | description                               |
      | member-all-reqs-met@example.com        | image.png | Image of a class completion certification |
      | member-no-guidelines@example.com       | image.png | Image of a class completion certification |
      | member-lapsed-all-reqs-met@example.com | image.png | Image of a class completion certification |

  # ============================================================================================

  Scenario: Member must agree to guidelines and has uploaded a doc since last payment
    Given the date is set to "2018-12-30"
    And I am logged in as "member-no-guidelines@example.com"
    When I am on the "user account" page
    Then I should see t("users.renewal.instructions")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And I should see t("users.uploaded_files_requirement.have_been_uploaded")
    And I should see t("users.uploaded_files_requirement.upload_another")
    And the link button t("users.renewal.pay_membership") should be disabled
    And I should see t("users.renewal.pay_button_disabled_info")


  Scenario: Member has already agreed to guidelines but not uploaded any docs
    Given the date is set to "2018-12-30"
    And I am logged in as "member-no-docs-uploaded@example.com"
    When I am on the "user account" page
    Then I should see t("users.renewal.instructions")
    And I should see t("users.ethical_guidelines_link_or_checklist.membership_guidelines")
    And I should see t("users.uploaded_files_requirement.need_to_upload")
    And I should see t("users.uploaded_files_requirement.upload_file")
    And the link button t("users.renewal.pay_membership") should be disabled
    And I should see t("users.renewal.pay_button_disabled_info")


  Scenario: Member has agreed to guidelines and uploaded a doc since last payment; payment button enabled
    Given the date is set to "2018-12-30"
    And I am logged in as "member-all-reqs-met@example.com"
    When I am on the "user account" page
    Then I should see t("users.renewal.instructions")
    And I should see t("users.ethical_guidelines_link_or_checklist.membership_guidelines")
    And I should see t("users.uploaded_files_requirement.have_been_uploaded")
    And I should see t("users.uploaded_files_requirement.upload_another")
    And the link button t("users.show.pay_membership") should not be disabled
    And I should not see t("users.renewal.pay_button_disabled_info")


  # --------------
  # Lapsed Member (membership has expired but is still in grace period for renewing)

  Scenario: Lapsed Member sees warning they are overdue to renew
    Given the date is set to "2019-01-01"
    And I am logged in as "member-lapsed-all-reqs-met@example.com"
    When I am on the "user account" page
    Then I should see t("users.renewal.title_renewal_overdue")
    And I should see t("users.renewal.renewal_overdue_warning")
    And I should see t("users.ethical_guidelines_link_or_checklist.membership_guidelines")
    And I should see t("users.uploaded_files_requirement.have_been_uploaded")
    And I should see t("users.uploaded_files_requirement.upload_another")
    And the link button t("users.show.pay_membership") should not be disabled
    And I should not see t("users.renewal.pay_button_disabled_info")
