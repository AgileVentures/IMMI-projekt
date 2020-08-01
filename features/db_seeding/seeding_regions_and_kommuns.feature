Feature: Seed Regions and Kommuns

  As an Admin
  So that regions and kommuns can be used in the application,
  And so that I don't have to enter them all by hand,
  I expect the regions and kommuns tables to be filled when the system is revised (when it's seeded).

  @db_seeding
  Scenario: 23 regions are created when it's initially seeded
    Given There are no "Regions" records in the db
    When the system is seeded with initial data
    Then 23 "Regions" records should be created

  @db_seeding
  Scenario: only 23 regions are ever created, even if it's seeded multiple times
    Given There are no "Regions" records in the db
    When the system is seeded with initial data
    Then 23 "Regions" records should be created

  @db_seeding
  Scenario: 290 kommuns are created when it's initially seeded
    Given There are no "Kommuns" records in the db
    When the system is seeded with initial data
    Then 290 "Kommuns" records should be created

  @db_seeding
  Scenario: only 290 kommuns are ever created, even if it's seeded multiple times
    Given There are no "Kommuns" records in the db
    When the system is seeded with initial data
    Then 290 "Kommuns" records should be created
