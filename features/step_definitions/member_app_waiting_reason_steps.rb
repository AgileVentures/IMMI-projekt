And(/the following member app waiting reasons exist/) do | table |

  table.hashes.each do | reason |
    FactoryGirl.create(:member_app_waiting_reason, reason)
  end

end


And(/^I should see (\d+) reasons? listed$/) do |number|
  page.assert_selector('.member_app_waiting_reason', count: number)
end


Given(/^I am on the edit member app waiting reason with name_sv "([^"]*)"$/) do | reason_name_sv |
  reason = AdminOnly::MemberAppWaitingReason.find_by_name_sv(reason_name_sv)
  visit path_with_locale(edit_admin_only_member_app_waiting_reason_path reason)
end

Given(/^I am on the edit member app waiting reason with name_sv t\("([^"]*)"\)$/) do | locale_reason_name_sv |
  reason = AdminOnly::MemberAppWaitingReason.find_by_name_sv(  i18n_content(locale_reason_name_sv) )
  visit path_with_locale(edit_admin_only_member_app_waiting_reason_path reason)
end


Given(/^I am on the member app waiting reason page for name_sv "([^"]*)"$/) do | reason_name_sv |
  reason = AdminOnly::MemberAppWaitingReason.find_by_name_sv(reason_name_sv)
  visit path_with_locale(admin_only_member_app_waiting_reason_path reason)
end


Given(/^I am on the member app waiting reason with name_sv t\("([^"]*)"\)$/) do | locale_reason_name_sv |
  reason = AdminOnly::MemberAppWaitingReason.find_by_name_sv(  i18n_content(locale_reason_name_sv) )
  visit path_with_locale(admin_only_member_app_waiting_reason_path reason)
end

