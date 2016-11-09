Feature: As a user
  In order to be a member
  I need to be able to apply

Scenario: Apply to be a member (Type A) to SHF
  Given I am on the application page
  When I fill in "user_first_name" with "Susanna"
  And I fill in "user_last_name" with "Larsdotter"
  And I fill in "user_street" with "Street abc 1"
  And I fill in "user_postal_code" with "30247"
  And I fill in "user_city" with "Halmstad"
  And I fill in "user_phone" with "0702-123456"
  And I fill in "user_email" with "susanna@immi.nu"
  And I fill in "user_email_confirmation" with "susanna@immi.nu"
  And I fill in "user_business_number" with "8509044643"
  And I fill in "user_password" with "password"
  And I fill in "user_password_confirmation" with "password"
  And I press the "Ansök om medlemsskap" button
  Then I should see "Welcome! You have signed up successfully."

Scenario Outline: User sign up sad path
  Given I am on the application page
  When I fill in the form with data :
  | user_first_name   | user_last_name   | user_street   | user_postal_code | user_city | user_email | user_email_confirmation | user_password | user_password_confirmation |
  | <fname>           | <lname>          | <street>      | <postcode>       | <city>    | <email>    | <email2>                | <pass>        | <pass2>                    |
  When I press the "Ansök om medlemsskap" button
  And I should see <error>

Scenarios:
  | fname | lname   | street      | postcode | city     | email      | email2     | pass     | pass2     | error |
  | Jenny | Rocker  | MyStreet 22 | 30274    | Halmstad | su@immi.se | su@immi.se | password | paswrd    | "Password confirmation doesn't match"  |
  |       | Rocker  | MyStreet 22 | 30274    | Halmstad | su@immi.se | su@immi.se | password | password  | "First name can't be blank"   |
  | Jenny |         | MyStreet 22 | 30274    | Halmstad | su@immi.se | su@immi.se | password | password  | "Last name can't be blank"   |
  | Jenny | Rocker  |             | 30274    | Halmstad | su@immi.se | su@immi.se | password | password  | "Street can't be blank"   |
  | Jenny | Rocker  | MyStreet 22 |          | Halmstad | su@immi.se | su@immi.se | password | password  | "Postal code can't be blank"   |
  | Jenny | Rocker  | MyStreet 22 | 22       | Halmstad | su@immi.se | su@immi.se | password | password  | "Postal code is the wrong length (should be 5 characters)" |
  | Jenny | Rocker  | MyStreet 22 | 30274    |          | su@immi.se | su@immi.se | password | password  | "City can't be blank"   |
  | Jenny | Rocker  | MyStreet 22 | 30274    | Halmstad | suimmi.se  | suimmi.se  | password | password  | "Email is invalid"    |
  | Jenny | Rocker  | MyStreet 22 | 30274    | Halmstad |            |            | password | password  | "Email can't be blank"     |
  | Jenny | Rocker  | MyStreet 22 | 30274    | Halmstad | su@immi.se | su@immi.se |          |           | "Password can't be blank"    |
