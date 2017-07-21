
# remove any leading locale path info
def current_path_without_locale(path)
  locale_pattern =  /^(\/)(en|sv)?(\/)?(.*)$/
  path.gsub(locale_pattern, '\1\4')
end

Then(/^I should be on the landing page$/) do
  expect(current_path_without_locale(current_path)).to eq root_path
end

And(/^I should see "([^"]*)"$/) do |content|
  expect(page).to have_content content
end

And(/^I should not see "([^"]*)"$/) do |content|
  expect(page).not_to have_content content
end

And(/^I should not see "([^"]*)" image$/) do |alt_text|
  expect(page).not_to have_xpath("//img[contains(@alt,'#{alt_text}')]")
end

And(/^I should see "([^"]*)" image$/) do |alt_text|
  expect(page).to have_xpath("//img[contains(@alt,'#{alt_text}')]")
end

And(/^I should see t\("([^"]*)"\)$/) do |content|
  expect(page).to have_content i18n_content(content)
end

And(/^I should not see t\("([^"]*)"\)$/) do |content|
  expect(page).not_to have_content i18n_content(content)
end

And(/^I should see t\("([^"]*)", locale: :(.*)\)$/) do |content, l|
  expect(page).to have_content i18n_content(content, l)
end

And(/^I should not see t\("([^"]*)", locale: :(.*)\)$/) do |content, l|
  expect(page).not_to have_content i18n_content(content, l)
end

And(/^I should see t\("([^"]*)", ([^:]*): ([^)]*)\), locale: :(.*)\)$/) do |content, key, value, l|
  expect(page).to have_content I18n.t("#{content}", key.to_sym => value, locale: l.to_sym)
end

And(/^I should not see t\("([^"]*)", ([^:]*): ([^)]*)\), locale: :(.*)\)$/) do |content, key, value, l|
  expect(page).not_to have_content I18n.t("#{content}", key.to_sym => value, locale: l.to_sym)
end

And(/^I should see t\("([^"]*)", ([^:]*): (\d+)\), locale: :(.*)$/) do |content, key, value, locale|
  expect(page).to have_content I18n.t("#{content}", key.to_sym => value, locale: locale.to_sym)
end

Then(/^I should see t\("([^"]*)", ([^:]*): "([^"]*)"\), locale: :(.*)$/) do |content, key, value, l|
  expect(page).to have_content I18n.t("#{content}", key.to_sym => value, locale: l.to_sym)
end

And(/^I should not see t\("([^"]*)", ([^:]*): (\d+)\), locale: :(.*)$/) do |content, key, value, locale|
  expect(page).not_to have_content I18n.t("#{content}", key.to_sym => value, locale: locale.to_sym)
end

And(/^I should see button "([^"]*)"$/) do |button|
  expect(page).to have_button button
end

And(/^I should not see button "([^"]*)"$/) do |button|
  expect(page).not_to have_button button
end

And(/^I should see button t\("([^"]*)"\)$/) do |button|
  expect(page).to have_button i18n_content(button)
end

And(/^I should not see button t\("([^"]*)"\)$/) do |button|
  expect(page).not_to have_button i18n_content(button)
end

And(/^I should see the checkbox with id "([^"]*)" unchecked$/) do |checkbox_id|
  expect(page).to have_unchecked_field checkbox_id
end

And(/^I should not see the checkbox with id "([^"]*)" unchecked$/) do |checkbox_id|
  expect(page).not_to have_unchecked_field checkbox_id
end

And(/^I should see the checkbox with id "([^"]*)" checked/) do |checkbox_id|
  expect(page).to have_unchecked_field checkbox_id
end

And(/^I should not see the checkbox with id "([^"]*)" checked/) do |checkbox_id|
  expect(page).not_to have_unchecked_field checkbox_id
end

And(/^I should see "([^"]*)" link$/) do |link_label|
  expect(page).to have_link link_label
end

And(/^I should see t\("([^"]*)"\) link$/) do |link_label|
  expect(page).to have_link i18n_content(link_label)
end

And(/^I should not see "([^"]*)" link$/) do |link_label|
  expect(page).not_to have_link link_label
end

And(/^I should not see t\("([^"]*)"\) link$/) do |link_label|
  expect(page).not_to have_link i18n_content(link_label)
end


Then(/^I should be on (?:the )*"([^"]*)" page$/) do |page|
  case page.downcase
    when  'login'
      path = new_user_session_path
    when 'landing'
      path = root_path
    when 'edit my application'
      path = edit_membership_application_path(@user.membership_applications.last)
    when 'show my application'
      path = membership_application_path(@user.membership_applications.last)
    when 'user instructions'
      path = information_path
    when 'member instructions'
      path = information_path
    when 'all waiting for info reasons'
      path = admin_only_member_app_waiting_reasons_path
    when 'new waiting for info reason'
      path = new_admin_only_member_app_waiting_reason_path
    when 'new waiting for info reason'
      path = new_admin_only_member_app_waiting_reason_path
    when 'register as a new user'
      path = new_user_registration_path
    when 'edit registration for a user'
      path = edit_user_registration_path
  end

  expect(current_path_without_locale(current_path)).to eq path
end


Then(/^I should see:$/) do |table|
  table.hashes.each do |hash|
    expect(page).to have_content hash[:content]
  end
end

And(/^"([^"]*)" should be set in "([^"]*)"$/) do |status, list|
  dropdown = page.find("##{list}")
  selected_option = dropdown.find('option[selected]').text
  expect(selected_option).to eql status
end

And(/^t\("([^"]*)"\) should be set in "([^"]*)"$/) do |status, list|
  dropdown = page.find("##{list}")
  selected_option = dropdown.find('option[selected]').text
  expect(selected_option).to eql i18n_content(status)
end


Then(/^I should be on the application page for "([^"]*)"$/) do |first_name|
  user = User.find_by(first_name: first_name)
  membership_application = user.membership_application
  expect(current_path_without_locale(current_path)).to eq membership_application_path(membership_application)
end

Then(/^I should be on the edit application page for "([^"]*)"$/) do |first_name|
  user = User.find_by(first_name: first_name)
  membership_application = user.membership_application
  expect(current_path_without_locale(current_path)).to eq edit_membership_application_path(membership_application)
end


Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('tr.applicant', count: number)
end

Then(/^I should see "([^"]*)" companies/) do |number|
  expect(page).to have_selector('tr.company', count: number)
end

Then(/^I should see "([^"]*)" business categories/) do |number|
  expect(page).to have_selector('tr.business_category', count: number)
end

Then(/^the field "([^"]*)" should have a required field indicator$/) do |label_text|
  expect(page.find('label', text: label_text)[:class].include?('required')).to be true
end

And(/^the field "([^"]*)" should not have a required field indicator$/) do |label_text|
  expect(page.find('label', text: label_text)[:class]).not_to have_css 'required'
end

Then(/^the field t\("([^"]*)"\) should have a required field indicator$/) do |label_text|
  expect(page.find('label', text: i18n_content(label_text))[:class].include?('required')).to be true
end

And(/^the field t\("([^"]*)"\) should not have a required field indicator$/) do |label_text|
  expect(page.find('label', text: i18n_content(label_text))[:class]).not_to have_css 'required'
end

Then(/^I should see (\d+) (.*?) rows$/) do |n, css_class_name|
  n = n.to_i
  expect(page).to have_selector(".#{css_class_name}", count: n)
  expect(page).not_to have_selector(".#{css_class_name}", count: n+1)
end


And(/^I should be on the applications page$/) do
  expect(current_path_without_locale(current_path)).to eq membership_applications_path
end

Then(/^I should see translated error (.*) (.*)$/) do |model_attribute, error|
  expect(page).to have_content("#{i18n_content(model_attribute)} #{i18n_content(error)}")
end

Then(/^I should see t\("([^"]*)", member_full_name: '([^']*)'\)$/) do |i18n_key, name_value|
 expect(page).to have_content(I18n.t(i18n_key, member_full_name: name_value))
end

And(/^I should see t\("([^"]*)", filename: '([^']*)'\)$/) do |i18n_key, filename_value|
  expect(page).to have_content(I18n.t(i18n_key, filename: filename_value))
end


And(/^I should see status line with status "([^"]*)" and date "([^"]*)"$/) do |status, date_string|
  expect(page).to have_content("#{status} - #{date_string}")
end

And(/^I should see status line with status t\("([^"]*)"\) and date "([^"]*)"$/) do |status, date_string|
  expect(page).to have_content("#{i18n_content(status)} - #{date_string}")
end

And(/^I should see status line with status t\("([^"]*)"\)$/) do |status|
  expect(page).to have_content("#{i18n_content(status)} - ")
end

And(/^I should not see status line with status t\("([^"]*)"\)$/) do |status|
  expect(page).not_to have_content("#{i18n_content(status)} - ")
end

And(/^I should see t\("([^"]*)", ([^:]*): (\d+)\)$/) do |content, key, number|
  expect(page).to have_content I18n.t("#{content}", key.to_sym => number)
end


And(/^I should see t\("([^"]*)", ([^:]*): "([^"]*)"\)$/) do |content, key, value|
  expect(page).to have_content I18n.t("#{content}", key.to_sym => value)
end


And(/^I should see t\("([^"]*)", ([^:]*): "([^"]*)", ([^:]*): "([^"]*)"\)$/) do | content, key1, value1, key2, value2 |
  expect(page).to have_content I18n.t("#{content}", key1.to_sym => value1, key2.to_sym => value2)
end

And(/^I should not see t\("([^"]*)", ([^:]*): "([^"]*)", ([^:]*): "([^"]*)"\)$/) do | content, key1, value1, key2, value2 |
  expect(page).not_to have_content I18n.t("#{content}", key1.to_sym => value1, key2.to_sym => value2)
end


Then(/^I should see t\("([^"]*)", authentication_keys: '([^']*)'\)$/) do |error, auth_key|
  expect(page).to have_content I18n.t("#{error}", authentication_keys: auth_key)
end

And(/^I should see (\d+) t\("([^"]*)"\)$/) do |n, content |
  n = n.to_i
  expect(page).to have_text("#{i18n_content(content)}", count: n)
  expect(page).not_to have_text("#{i18n_content(content)}", count: n+1)
end

Then(/^t\("([^"]*)"\) should( not)? be visible$/) do |string, not_see|
  unless not_see
    expect(has_text?(:visible, "#{i18n_content(string)}")).to be true
  else
    expect(has_text?(:visible, "#{i18n_content(string)}")).to be false
  end
end


# Have to be sure to wait for any javascript to execute since it may hide or show an item
Then(/^item "([^"]*)" should( not)? be visible$/) do | item, negate|

  if negate
    expect(page).to have_field(item, visible: false)

  else
    expect( find_field(item).visible? ).to be_truthy
  end

end


# Tests that an input or button with the given label is disabled.
Then /^the "([^\"]*)" (field|button|item) should( not)? be disabled$/ do |label, kind, negate|

  if kind == 'field'
    element = find_field(label)
  elsif kind == 'button'
    element = find_button(label)
  else
    element = find(label)
  end

  expect(["false", "", nil]).send(negate ? :to : :not_to,  include(element[:disabled]) )

end


# Tests that an input has a given value
Then /^the t\("([^"]*)"\) field should be set to "([^\"]*)"$/ do |i18n_key, text_value|

  element = find_field(I18n.t(i18n_key))

  expect(element.value).to eq(text_value)

end


Then(/^I should see link "([^"]*)" with target = "([^"]*)"$/) do |link_identifier, target_value|
  expect(find_link(link_identifier)[:target]).to eq(target_value)
end

And(/^I should see t\("([^"]*)"\), locale: :(\w\w)$/) do |i18n_key, locale|
  expect(page).to have_content I18n.t(i18n_key, locale: locale)
end


And(/^I should not see t\("([^"]*)"\), locale: :(\w\w)$/) do |i18n_key, locale|
  expect(page).not_to have_content I18n.t(i18n_key, locale: locale)
end

And(/^I should see the selector "([^"]*)"$/) do | s |
  expect(page).to have_selector(s)
end

And(/^I should see flash text t\("([^"]*)"\)$/) do | i18n_key |
  expect(page).to have_selector('#flashes', text: I18n.t(i18n_key) )
end

And(/^I should see "([^"]*)" in the row for user "([^"]*)"$/) do | expected_text, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td
  expect(tr.text).to match(Regexp.new(expected_text))
end

And(/^I should see t\("([^"]*)"\) in the row for user "([^"]*)"$/) do | expected_text, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td
  expect(tr.text).to match(Regexp.new(I18n.t(expected_text)))
end


And(/^I should not see "([^"]*)" in the row for user "([^"]*)"$/)do | expected_text, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td
  expect(tr.text).not_to match(Regexp.new(expected_text))
end


And(/^I should not see t\("([^"]*)"\) in the row for user "([^"]*)"$/) do | expected_text, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td
  expect(tr.text).not_to match(Regexp.new(I18n.t(expected_text)))
end

And(/^I should see "([^"]*)" for class "([^"]*)" in the row for user "([^"]*)"$/) do |expected_text, css_class, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(tr).to have_css(".#{css_class}", text: expected_text)
end

And(/^I should not see "([^"]*)" for class "([^"]*)" in the row for user "([^"]*)"$/) do |expected_text, css_class, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(tr).not_to have_css(".#{css_class}", text: expected_text)
end


And(/^I should see t\("([^"]*)"\) for class "([^"]*)" in the row for user "([^"]*)"$/) do |expected_text, css_class, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(tr).to have_css(".#{css_class}", text: I18n.t(expected_text))
end

And(/^I should not see t\("([^"]*)"\) for class "([^"]*)" in the row for user "([^"]*)"$/) do |expected_text, css_class, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(tr).not_to have_css(".#{css_class}", text: I18n.t(expected_text))
end


And(/^I should see xpath "([^"]*)"$/) do | xp |
  expect(page).to have_xpath(xp)
end

Then(/^I should( not)? see "([^"]*)" before "([^"]*)"$/) do |not_see, toSearch, last|
  assert_text toSearch
  regex = /#{Regexp.quote("#{toSearch}")}.+#{Regexp.quote("#{last}")}/
  if not_see
    assert_no_text regex
  else
    assert_text regex
  end
end


And(/^I should be on the SHF document page for "([^"]*)"$/)  do | doc_title |
    shf_doc = ShfDocument.find_by_title(doc_title)
  expect(current_path_without_locale(current_path)).to eq shf_document_path(shf_doc)
end


Then(/^all addresses for the company named "([^"]*)" should( not)? be geocoded$/) do | company_name, no_geocode |

  co = Company.find_by_name(company_name)
  if no_geocode
    expect( co.addresses.reject(&:geocoded? ).count).not_to be 0
  else
    expect( co.addresses.reject(&:geocoded? ).count).to be 0
  end

end


# Checks that a certain option is selected for a text field (from https://github.com/makandra/spreewald)
Then /^"([^"]*)" should( not)? have t\("([^"]*)"\) selected$/ do |select_list, negate, expected_string |

    field = find_field(select_list)

    field_value = case field.tag_name
                    when 'select'
                      options = field.all('option')
                      selected_option = options.detect(&:selected?) || options.first
                      if selected_option && selected_option.text.present?
                        selected_option.text.strip
                      else
                        ''
                      end
                    else
                      field.value
                  end


    expect(field_value).send( (negate ? :not_to : :to),  eq(i18n_content(expected_string)) )

end



# Checks that a certain option is selected for a text field (from https://github.com/makandra/spreewald)
Then /^"([^"]*)" should( not)? have "([^"]*)" selected$/ do | select_list, negate, expected_string |

  field = find_field(select_list)

  field_value = case field.tag_name
                  when 'select'
                    options = field.all('option')
                    selected_option = options.detect(&:selected?) || options.first
                    if selected_option && selected_option.text.present?
                      selected_option.text.strip
                    else
                      ''
                    end
                  else
                    field.value
                end

  expect(field_value).send( (negate ? :not_to : :to),  eq(expected_string) )

end



# Checks that a certain option does or does not exist in a select list
Then /^"([^"]*)" should( not)? have t\("([^"]*)"\) as an option/ do | select_list, negate, expected_string |

  field = find_field(select_list)

  select_options= case field.tag_name
                  when 'select'
                    options = field.all('option')
                end
  expect(select_options.map(&:text)).send( (negate ? :not_to : :to),  include( i18n_content expected_string) )

end


Then(/^I should be on the all member app waiting reasons page$/) do
  expect(current_path_without_locale(current_path)).to eq admin_only_member_app_waiting_reasons_path
end
