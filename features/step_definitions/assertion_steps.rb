
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


Then(/^I should be on "([^"]*)" page$/) do |page|
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
  membership_application = MembershipApplication.find_by(first_name: first_name)
  expect(current_path_without_locale(current_path)).to eq membership_application_path(membership_application)
end

Then(/^I should be on the edit application page for "([^"]*)"$/) do |first_name|
  membership_application = MembershipApplication.find_by(first_name: first_name)
  expect(current_path_without_locale(current_path)).to eq edit_membership_application_path(membership_application)
end


Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('.applicant', count: number)
end

Then(/^I should see "([^"]*)" companies/) do |number|
  expect(page).to have_selector('.company', count: number)
end

Then(/^I should see "([^"]*)" business categories/) do |number|
  expect(page).to have_selector('.business_category', count: number)
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
