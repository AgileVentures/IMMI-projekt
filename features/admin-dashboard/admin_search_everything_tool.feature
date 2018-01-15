Feature: Admin can search on everything and save results

  As an admin
  So that I can explore and understand the information in the system
  I need to be able to search on everything, including combinations of everything
  And so that I can share the information I find
  I need to be able to export the results as CSV or Text)

  I do not want to have to go to separate pages (e.g. 'users,' 'membership applications, etc')
  and then manually put together the info.
  Let me search on different combinations.

  I would really like to be able to save searches so I can run them again.


  Background:

    Given the following users exists
      | email                       | admin | member |
      | emma_member@mutts.se        |       | true   |
      | hans_member@mutts.se        |       | true   |
      | anna@nosnarkybarky.se       |       |        |
      | lars_under_review@mutts.com |       |        |
      | admin@shf.com               | true  |        |

    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | rehab        | physical rehabilitation         |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name        | company_number | email               | region    |
      | Bow Wow Wow | 5560360793     | hellow@bowwowwow.se | Stockholm |
      | Mutts R Us  | 5562252998     | voof@mutts.se       | Stockholm |

    And the following applications exist:
      | user_email                 | company_number | categories   | state        |
      | emma_member@mutts.se       | 5562252998     | rehab        | accepted     |
      | hans_member@mutts.se       | 5562252998     | dog grooming | accepted     |
      | lars_under_review@mutts.se | 5562252998     | dog grooming | under_review |
      | anna@nosnarkybarky.se      | 5560360793     | rehab        | under_review |

    And I am logged in as "admin@shf.se"

