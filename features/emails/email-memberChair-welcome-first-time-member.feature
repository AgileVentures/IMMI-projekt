Feature: Membership chair gets an email when a first-time-ever membership has been granted.

  As the membership chair,
  So that I can welcome a new member on social media, send a membership package, etc.,
  I should get an email when someone has been granted membership for the first time
  and they have joined a Company (and the company is in good standing).


  Pivotal Tracker story: https://www.pivotaltracker.com/story/show/169273314


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                       | admin | membership_status | first_name    | last_name |
      | lars-member@lars.se         |       | current_member    | Lars          | Member    |
      | new-member@good-standing.se |       |                   | good-standing | Applicant |
      | new-member@no-h-brand.se    |       |                   | no-h-brand    | Applicant |
      | admin@shf.com               | true  |                   | admin         | admin     |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                       |
      | lars-member@lars.se         |
      | new-member@good-standing.se |
      | new-member@no-h-brand.se    |

    And the following business categories exist
      | name    |
      | Groomer |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name                             | company_number | email                 | region    |
      | AlreadyInGoodStanding            | 5562252998     | voof@good-standing.se | Stockholm |
      | NewCompany Needs H-brand payment | 2120000142     | voof@new-company.se   | Stockholm |
      | Company With no H-branding       | 6613265393     | voof@no-h-brand.se    | Stockholm |


    And the following applications exist:
      | user_email                  | company_number         | categories | state    |
      | lars-member@lars.se         | 5562252998, 2120000142 | Groomer    | accepted |
      | new-member@good-standing.se | 5562252998             | Groomer    | accepted |
      | new-member@no-h-brand.se    | 6613265393             | Groomer    | accepted |

    And the date is set to "2020-01-01"
    Given the following payments exist
      | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
      | lars-member@lars.se | 2020-01-01 | 2020-12-31  | member_fee   | betald | none    |                |
      | lars-member@lars.se | 2020-01-01 | 2020-12-31  | branding_fee | betald | none    | 5562252998     |

    And these files have been uploaded:
      | user_email                  | file name | description                               |
      | lars-member@lars.se         | image.png | Image of a class completion certification |
      | new-member@good-standing.se | image.png | Image of a class completion certification |
      | new-member@no-h-brand.se    | image.png | Image of a class completion certification |


    And the following memberships exist:
      | email               | first_day  | last_day   |
      | lars-member@lars.se | 2020-01-01 | 2020-12-31 |

  # ===========================================================================================


  Scenario: New Member granted membership for a leap year. Email is sent when membership is granted.
    Given the date is set to "2020-01-05"
    And a clear email queue
    And I am logged in as "new-member@good-standing.se"
    And I have agreed to all of the Membership Guidelines
    And I am on the "user account" page
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And "membership@example.org" should receive an email with subject t("mailers.admin_mailer.new_membership_granted_co_hbrand_paid.subject")
    And my membership expiration date should be 2021-01-04


  Scenario: Already a member. Then H-Branding license payment is made, putting the New company into "good standing" and email is sent then.
    Given the date is set to "2020-01-05"
    And a clear email queue
    And I am logged in as "lars-member@lars.se"
    And I am on the page for company number "2120000142"
    Then I should see "NewCompany Needs H-brand payment"
    And I should see t("payors.due")
    When I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "NewCompany Needs H-brand payment"
    Then I should see t("payments.success.success")
    And company number "2120000142" is paid through "2021-01-04"
    And "membership@example.org" should receive an email with subject t("mailers.admin_mailer.new_membership_granted_co_hbrand_paid.subject")


  Scenario: Membership is granted, but company is not in good standing. No email sent.
    Given the date is set to "2020-01-05"
    And a clear email queue
    And I am logged in as "new-member@no-h-brand.se"
    And I have agreed to all of the Membership Guidelines
    When I am on the "user account" page
    Then I should see t("users.show_for_applicant.pay_membership")
    When I click on t("users.show_for_applicant.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And "membership@example.org" should receive no email with subject t("mailers.admin_mailer.new_membership_granted_co_hbrand_paid.subject")


    # Company H-Branding fees are paid through 2022-11-30.
    # Then it is 2021-01-05 and Lars' membership has expired.
    # Then he pays and renews.
    # He is not a first time member, so no email is sent.
  Scenario: Not a first-time member when membership granted. No email sent.
    Given the date is set to "2020-12-01"
    When I am logged in as "lars-member@lars.se"
    And a clear email queue
    Then my membership expiration date should be 2020-12-31

    When I am the page for company number "2120000142"
    Then I should see "NewCompany Needs H-brand payment"
    And I should see t("payors.due")
    When I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "NewCompany Needs H-brand payment"
    Then I should see t("payments.success.success")
    And company number "2120000142" is paid through "2021-11-30"
    And my membership expiration date should be 2020-12-31

    When I am the page for company number "5562252998"
    And the date is set to "2020-12-01"
    Then I should see "AlreadyInGoodStanding"
    And I should see t("payors.due")
    When I click on t("menus.nav.company.pay_branding_fee")
    And I complete the branding payment for "AlreadyInGoodStanding"
    Then I should see t("payments.success.success")
    And company number "5562252998" is paid through "2021-12-31"
    And my membership expiration date should be 2020-12-31
    And I am logged out

    Given the date is set to "2021-01-05"
    And a clear email queue
    When I am logged in as "lars-member@lars.se"
    Then my membership expiration date should be 2020-12-31

    When I am on the "user account" page
    Then I should see t("users.show_for_applicant.pay_membership")
    When I click on t("users.show_for_applicant.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And "membership@example.org" should receive no email with subject t("mailers.admin_mailer.new_membership_granted_co_hbrand_paid.subject")
