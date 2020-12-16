# Steps for UserChecklist items

require 'cucumber/rspec/doubles'


# These must all start with 'USERCHECKLIST' because Cucumber will add them to the list of all constants defined in all step files (so they must be unique)

USERCHECKLISTS_ID = 'user-checklists'.freeze
USERCHECKLIST_TABLE_ID = USERCHECKLISTS_ID

USERCHECKLIST_LIST_CSSCLASS = 'checklist'.freeze
USERCHECKLIST_LISTITEM_CSSCLASS = 'checklist-item'.freeze

USERCHECKLIST_ITEM_ROW_CSSCLASS = 'ordered-list-entry' # TODO this doesn't seem correct.

USERCHECKLIST_NAME_CSSCLASS = 'name'.freeze
USERCHECKLIST_DISPLAYED_TEXT_CSSCLASS = 'displayed-text'.freeze
USERCHECKLIST_LIST_POSITION_CSSCLASS = 'list-position'.freeze

USERCHECKLIST_PARENT_LIST_ID = 'ordered_list_entry_parent_id' # TODO parent list? master list?

USERCHECKLIST_DATECOMPLETED_DESC_XPATHSTR = "./span[contains(concat(' ',normalize-space(@class),' '),' date-completed ')]".freeze


# --------------------------------------------------------------------------
# Helper methods for getting specific HTML elements


# XPath string for locating an HTML element with
#  a CSS class :element_class
#  containing text :text
#  and an ancestor with CSS class :ancestor_class
#
# TODO -move this to a different steps file
#
def xpathstr_ancestor_class_element_class_and_text(ancestor_class: USERCHECKLIST_LISTITEM_CSSCLASS,
                                                   element_class: '',
                                                   text: '')
  ".//*[#{xpath_for_element_with_class(ancestor_class)}]//*[(#{xpath_for_element_with_class(element_class)}) and contains(text(), '#{text}')]"
end


# Verify that the element has the xpath, then find and return it.
#
# TODO -move this to a different steps file
#
def verify_and_get_element_from(starting_element, xpath_string)
  expect(starting_element).to have_xpath(xpath_string) # If this fails, the element could not be found (assuming the xpath string is correct)
  starting_element.find(:xpath, xpath_string)
end


def get_checklist_li_item_element(text = '', starting_element = page)
  checklist_li_xpath_str = ".//li[#{xpath_for_element_with_class(USERCHECKLIST_LISTITEM_CSSCLASS)}]//*[contains(text(), '#{text}')]"
  checklist_li_element = verify_and_get_element_from(starting_element, checklist_li_xpath_str)

  # return the parent li element
  parent_xpath_str = 'parent::li'
  verify_and_get_element_from(checklist_li_element, parent_xpath_str)
end


def xpathstr_for_item_span_displayed_text(item_displayed_text = '')
  xpathstr_ancestor_class_element_class_and_text(ancestor_class: USERCHECKLIST_LISTITEM_CSSCLASS,
                                                 element_class: USERCHECKLIST_DISPLAYED_TEXT_CSSCLASS,
                                                 text: item_displayed_text)
end


# return the visible AND not visible date completed HTML element for the date completed for a list named :list_name
# We will return the element even if is not visible so that the text can be checked even if it's not visible
def get_date_completed_element_for_list(list_name = '', visible: :visible)
  date_completed_list_element = get_checklist_li_item_element(list_name)
  expect(date_completed_list_element).to have_xpath(USERCHECKLIST_DATECOMPLETED_DESC_XPATHSTR, visible: visible)
  date_completed_list_element.find(:xpath, USERCHECKLIST_DATECOMPLETED_DESC_XPATHSTR, visible: visible)
end


# return the HTML element for the checkbox for a list named :list_name
def get_checkbox_element_for_list(list_name = '')
  checklists_list_element = get_checklist_li_item_element(list_name)
  checklists_list_element.find(:xpath, "./input")
end


# ------------------------------------------------------------------


And(/^the following user checklist items have been completed:$/) do |table|
  table.hashes.each do |item|

    user_email = item.delete('user email') || ''
    checklist_name = item.delete('checklist name') || ''
    date_completed = item.delete('date completed') || nil

    begin
      user = User.find_by(email: user_email)
      master_checklist = AdminOnly::MasterChecklist.find_by(name: checklist_name)
      user_checklist = UserChecklist.find_by(user: user, master_checklist: master_checklist)
    rescue => e
      raise e, "Could not find either the user or user_checklist (user_email: #{user_email}, checklist_name: #{checklist_name})\n #{e.inspect} "
    end

    user_checklist.update(date_completed: date_completed)
  rescue => e
    raise e, "Could not update the user checklist with the date completed. user_checklist: #{user_checklist.inspect}, date_completed: #{date_completed}\n #{e.inspect} "

  end
end


And(/^the following user checklists exist:$/) do |table|
  table.hashes.each do |item|

    user_email = item.delete('user email') || ''
    checklist_name = item.delete('checklist name') || ''

    user = User.find_by(email: user_email)
    checklist_master = AdminOnly::MasterChecklist.find_by(name: checklist_name)

    # The ancestry must be constructed, so we cannot use a FactoryBot.
    # (The ancestry gem requires ActiveRecord to make the ancestry / keep the ancestry updated.)

    begin
      user_checklist = AdminOnly::UserChecklistFactory.create_for_user_from_master_checklist(user, checklist_master)
      user_checklist
      # user_checklist = UserChecklist.find_or_create_by!(user: user, checklist: master_checklist) do | u_checklist|
      #   u_checklist.date_completed = date_completed
      #   u_checklist.list_position = master_checklist.list_position
      # end
    rescue => e
      raise e, "Could not find_or_create_by!(user: #{user.inspect}, checklist: #{checklist_master.inspect}) the Userhecklist\n #{e.inspect} "
    end
  end
end



And("the start date for the Membership Ethical Guidelines is {date}") do | req_start_date |
  allow(UserChecklistManager).to receive(:membership_guidelines_reqd_start_date).and_return(req_start_date)
end


And("I should{negate} see the checklist {capture_string} in the list of user checklists") do |negated, displayed_text|
  list_locator = "##{USERCHECKLISTS_ID}"
  if page.has_selector?(list_locator)
    uchecklist_displayed_text_span_xpath = xpathstr_for_item_span_displayed_text(displayed_text)
    expect(page.find(list_locator)).send((negated ? :not_to : :to), have_xpath(uchecklist_displayed_text_span_xpath))

  else
    # if we expect a list item _not_ to be there (== negated) and the list isn't on the page,
    #  then we know that there are no list items at all, so we can return true.
    #  Else we _are_ expecting a list item to be there, but since there's no list, we fail (and so return false).
    expect(!!negated).to be_truthy, "Expected user checklist '#{displayed_text}' not found. No user checklists were on the page at all."
  end
end


When("I {action} the checkbox for the user checklist {capture_string}") do |check_or_uncheck, item_name|
  checkbox_element = get_checkbox_element_for_list(item_name)
  case check_or_uncheck
    when 'check'
      checkbox_element.check
      expect(checkbox_element.checked?).to be_truthy
    when 'uncheck'
      checkbox_element.uncheck
      expect(checkbox_element.checked?).to be_falsey
  end
end


Then("the checkbox for the user checklist {capture_string} should{negate} be checked") do |list_name, negated|
  checkbox_element = get_checkbox_element_for_list(list_name)
  expect(checkbox_element.checked?).send((negated ? :not_to : :to), be_truthy)
end


And("the checkbox for the user checklist {capture_string} should{negate} be disabled") do | list_name, negated|
  checkbox_element = get_checkbox_element_for_list(list_name)
  expect(checkbox_element.disabled?).send((negated ? :not_to : :to), be_truthy )
end


Then("I should see the date completed as {date} for the user checklist {capture_string}") do |completed_date, list_name|
  date_completed_ele = get_date_completed_element_for_list(list_name)
  expect(date_completed_ele.text().include?(completed_date.to_s)).to be_truthy
end


Then("I should{negate} see a date completed for the user checklist {capture_string}") do |negated, list_name|
  date_completed_ele = get_date_completed_element_for_list(list_name, visible: (negated ? :all : :visible))

  # Must explicitly use 'text()' (with the parentheses) to get the element text (that is how Capybara sends the message to the Node)
  expect(date_completed_ele.text()).send((negated ? :to : :not_to), be_blank)
end


# -------------
# in tables

And("I should see the item named {capture_string} in the user checklist items table") do |item_name|
  step %{I should see CSS class "name" with text "#{item_name}" in the table with id "#{USERCHECKLIST_TABLE_ID}"}
end


And("I should see {capture_string} as the user checklist in the row for {capture_string}") do |user_checklist_name, user_checklist_item_name|
  # verify that this user_checklist_item is in the table
  step %{I should see the item named "#{user_checklist_item_name}" in the user checklist items table}

  table = page.find("table#user-checklist-items")
  item_name_td = table.find(:xpath, "tbody/tr/td[@class='name' and .//text()='#{user_checklist_item_name}']")
  item_name_tr = item_name_td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(item_name_tr).to have_xpath("./td[@class='user-checklist' and .//text()='#{user_checklist_name}']")
end

# ------------------
# on a page (not in a table or list)


And("I check the box {capture_string}") do | checkbox_name |
  page.check(checkbox_name)
end


# Set all of the Membership Guidelines user checklists to completed for the current user
# Create the Membership Guidelines user checklist(s) for the user if needed
And ("I have agreed to all of the Membership Guidelines") do
  user_guidelines = if (found_guidelines = UserChecklistManager.membership_guidelines_list_for(@user))
                      found_guidelines
                    else
                      AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(@user) unless UserChecklistManager.membership_guidelines_list_for(@user)
                    end
  user_guidelines.set_complete_including_children
end

And("I should{negate} see {capture_string} as the guideline name to agree to") do | negate, guideline_name |
  guideline =  page.find_by_id("guideline-name")
  expect(guideline).send (negate ? :not_to : :to), have_content(/#{guideline_name}/i)
end

And("I am on the page for checklist item {capture_string}") do | checklist_name |
  checklist = UserChecklist.find_by(user: @user, name: checklist_name)
  path = user_user_checklist_path(@user, checklist.id)
  visit path_with_locale(path)
end
