Feature: User completes all, some, or none of the Membership Ethical Guidelines checklist

  Rule: The user can agree to the guidelines independent of whether or not they have submitted an application.

  Background:
  Given the Membership Ethical Guidelines Master Checklist exists

  And the following users exist:
    | email                | admin | first_name | last_name |
    | new_user@example.com |       | NewUser1   | Lastname  |


  @selenium @javascript
  Scenario: User checks all guidelines - completes the list
    Given I am logged in as "new_user@example.com"
    And the date is set to "2021-02-03"
    And I am on the "user account" page for "new_user@example.com"
    When I click on t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines") link
    Then I should be on the "first unchecked membership guideline" page for "new_user@example.com"
    And I should see "Medlemsåtagande" in the h1 title
    And I should see "0%"
    And I should see "Section 1" as the guideline name to agree to

    When I check the bootstrap checkbox with id "completed-checkbox"

    # Have to wait so that all AJAX and db can complete before capybara tries to reload the page
    And I wait for 1 seconds
    # Have to reload the page to see the change since no jquery is running
#    And I reload the page
    Then I should see "67%"
    And I should see t("next")

    When I click on t("next") link
    Then I should see "Section 2" as the guideline name to agree to

    When I check the bootstrap checkbox with id "completed-checkbox"
     # Have to wait so that all AJAX and db can complete before capybara tries to reload the page
    And I wait for 1 seconds

    # Have to reload the page to see the change since no jquery is running
    And I reload the page
    Then I should see "100%"
    And I should see t("user_checklists.membership_guidelines_completed.agreed_to_all_terms")
    And I should see t("user_checklists.membership_guidelines_completed.back_to_my_profile")

    And I should not see t("next")

    When I am on the "user account" page for "new_user@example.com"
    And I should not see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And I should see t("users.ethical_guidelines_link_or_checklist.agreed_to", date: '2021-02-03')


  @selenium  @javascript
  Scenario: User checks only some of the guidelines
    Given I am logged in as "new_user@example.com"
    And I am on the "user account" page for "new_user@example.com"
    When I click on t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines") link
    Then I should be on the "first unchecked membership guideline" page for "new_user@example.com"
    And I should see "Medlemsåtagande" in the h1 title
    And I should see "0%"
    And I should see "Section 1" as the guideline name to agree to

    When I check the bootstrap checkbox with id "completed-checkbox"
    # Have to wait so that all AJAX and db can complete before capybara tries to reload the page
    And I wait for 1 seconds
    # Have to reload the page to see the change since no jquery is running
    And I reload the page
    Then I should see "67%"
    And I should see t("next")

    When I am on the "user account" page for "new_user@example.com"
    Then I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")

    When I click on t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines") link
    Then I should see "67%"
    And I should see "Section 2" as the guideline name to agree to


  @selenium @javascript
  Scenario: User checks none of the guidelines
    Given I am logged in as "new_user@example.com"
    And I am on the "user account" page for "new_user@example.com"
    When I click on t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines") link
    Then I should be on the "first unchecked membership guideline" page for "new_user@example.com"
    And I should see "Medlemsåtagande" in the h1 title
    And I should see "0%"
    And I should see "Section 1" as the guideline name to agree to

    When I am on the "user account" page for "new_user@example.com"
    Then I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")

    When I click on t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines") link
    Then I should see "0%"
    And I should see "Section 1" as the guideline name to agree to
