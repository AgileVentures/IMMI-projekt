Feature: As a visitor
  In order to view the site in my language
  I need to be able choose either Swedish or English for the site

  PT: https://www.pivotaltracker.com/story/show/133316647

  Note that we always explicitly start with the locale set to sv. This is
  necessary in case the feature are being run with a different locale.

  Background:
    Given I am Logged out


  Scenario: Default language is Swedish
    Given I set the locale to "sv"
    And I am on the "all companies" page
    Then I should see t("companies.index.title")
    And I should not see t("show_in_swedish") image
    And I should see t("show_in_english") image


  Scenario: Visitor switches the site language from English to Swedish
    Given I set the locale to "sv"
    And I am on the "all companies" page
    When I click on "change-lang-to-english"
    When I click on "change-lang-to-svenska"
    Then I should see t("companies.index.title")
    And I should not see t("show_in_swedish") image
    And I should see t("show_in_english") image


  Scenario: Visitor switches the site language from Swedish to English
    Given I set the locale to "sv"
    And I am on the "all companies" page
    When I click on "change-lang-to-english"
    Then I should see t("show_in_swedish") image
    And I should not see t("show_in_english") image
