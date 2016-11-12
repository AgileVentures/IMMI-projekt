Feature: As an Admin
  So that we can accept or reject new Memberships,
  I need to review a Membership Application that has been submitted
  PT: https://www.pivotaltracker.com/story/show/133950343

Background:
Given the following applications exist:
  | company_name | company_number | contact_person | phone_number | company_email |
  | Hunderiet    | 1234567890     | Emma Svensson  | 1234-234567  | min@mail.se   |
  | DoggieZone   | 2345678901     | Pam Andersson  | 0234-234567  | din@mail.se   |
  | Tassa-in AB  | 1234367890     | Anna Knutsson  | 1234-234569  | sin@mail.se   |

Scenario: Listing incoming Applications
  Given I am on the list applications page
  Then I should see "3" applications
  When I click on "DoggieZone"
  Then I should be on "DoggieZone" page
  And I should see:
    | content       |
    | 2345678901    |
    | Pam Andersson |
    | 0234-234567   |
    | din@mail.se   |
