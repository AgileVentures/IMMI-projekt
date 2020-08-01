# Steps for viewing and working with menus

# This is hard-coded to only look for the login menu,
#   but could be generalized to handle any of the main navigation (drop-down) menus if/when needed.
Then("I should{negate} see {capture_string} in the login menu") do | negate, menu_text  |
  menu = page.find('.login-nav')
  expect(menu).send (negate ? :not_to : :to), have_link(menu_text)
end
