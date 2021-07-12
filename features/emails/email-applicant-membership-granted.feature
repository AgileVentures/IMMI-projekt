Feature: Applicant gets an email when membership has been granted. (They are now a member).

  As an applicant,
  So that I am notified that I am now a member
  and so I know what I should expect to happen next,
  I should get an email telling me I'm a member and explaining what I need to do next
  And the email should include a link to my company page
  So that I can pay the branding fee (if needed) and then perhaps edit my company information


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email              | admin |
      | member@mutts.se |       |
      | admin@shf.com      | true  |


    And the following business categories exist
      | name    |
      | Groomer |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name        | company_number | email              | region    |
      | Happy Mutts | 5562252998     | voof@happymutts.se | Stockholm |

    And the following applications exist:
      | user_email         | company_number | categories | state    |
      | member@mutts.se | 5562252998     | Groomer    | accepted |


    And these files have been uploaded:
      | user_email      | file name | description                               |
      | member@mutts.se | image.png | Image of a class completion certification |

  # ============================================================================================

  @time_adjust
  Scenario: Applicant pays all fees, membership is granted; applicant gets email
    Given the date is set to "2018-01-01"
    And the App Configuration is not mocked and is seeded
    When I am in "member@mutts.se" browser
    And I am logged in as "member@mutts.se"
    And I have agreed to all of the Membership Guidelines
    And I am on the "user details" page for "member@mutts.se"
    And I should see t("menus.nav.members.pay_membership")
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    Then I am on the "user account" page
    And I should see "2018-12-31"
    And I should be a member
    Then "member@mutts.se" should receive an email
    And I am logged in as "member@mutts.se"
    And I open the email
    And I should see t("mailers.member_mailer.membership_granted.subject") in the email subject
    And I should see t("mailers.member_mailer.membership_granted.message_text.welcome") in the email body
    And I should see t("mailers.member_mailer.membership_granted.message_text.youre_active") in the email body
    And I should see ""Sveriges Hundföretagare" <from@example.org>" in the email "from" header
    And I should see ""Sveriges Hundföretagare" <reply@example.org>" in the email "reply-to" header
    And I should not see "http://localhost:3000/hundforetag/1/redigera" in the email body
    And I should see "http://localhost:3000/hundforetag/1" in the email body
    When I follow "http://localhost:3000/hundforetag/1" in the email
    Then I should see "Happy Mutts"
    And I should see "Groomer"


  @time_adjust   @selenium
  Scenario: [SAD PATH] Applicant does not pay all fees, membership is not granted; no email is sent (2017)
    Given the date is set to "2017-12-31"
    When I am in "member@mutts.se" browser
    And I am logged in as "member@mutts.se"
    And I have agreed to all of the Membership Guidelines
    And I am on the "user details" page for "member@mutts.se"
    And I should see t("menus.nav.members.pay_membership")
    Then I click on t("menus.nav.members.pay_membership")
    And I abandon the payment by going back to the previous page
    And I should not see t("payments.confirmation.success_html")
    Then "member@mutts.se" should receive no emails


  @time_adjust   @selenium
  Scenario: [SAD PATH] Applicant does not pay all fees, membership is not granted; no email is sent (post 2017)
    Given the date is set to "2018-01-01"
    When I am in "member@mutts.se" browser
    And I am logged in as "member@mutts.se"
    And I have agreed to all of the Membership Guidelines
    And I am on the "user details" page for "member@mutts.se"
    And I should see t("menus.nav.members.pay_membership")
    Then I click on t("menus.nav.members.pay_membership")
    And I abandon the payment by going back to the previous page
    And I should not see t("payments.confirmation.success_html")
    Then "member@mutts.se" should receive no emails
