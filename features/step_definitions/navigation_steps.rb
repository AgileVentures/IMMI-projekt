Given(/^I am on the "([^"]*)" page(?: for "([^"]*)")?$/) do |page, email|
  user = email == nil ? @user :  User.find_by(email: email)

  begin
    visit path_with_locale(get_path(page, user))
  rescue => exception
    warn exception.message
    begin
      path_components = page.split(/\s+/)
      visit self.send(path_components.push('path').join('_').to_sym)
    rescue NoMethodError, ArgumentError
      raise "Can't find mapping from \"#{page}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__} or assertion_steps.rb"
    end
  end


end


When(/^I fail to visit the "([^"]*)" page$/) do |page|
  path = get_path(page)
  visit path_with_locale(path)
  expect(current_path).not_to be path
end


When(/^I am on the static workgroups page$/) do
  visit page_path('yrkesrad')
end


When(/^I am on the test member page$/) do
  path = File.join(Rails.root, 'spec', 'fixtures',
                   'member_pages', 'testfile.html')

  allow_any_instance_of(ShfDocumentsController).to receive(:page_and_file_path)
    .and_return([ 'testfile', path ])

  visit contents_show_path('testfile')
end

Then(/^(?:I|they) click the browser back button and "([^"]*)" the prompt$/) do |modal_action|
  case modal_action
  when 'accept'  # accept == leave page
    page.accept_confirm { page.evaluate_script('window.history.back()') }

  when 'dismiss' # dismiss == stay on page
    page.dismiss_confirm { page.evaluate_script('window.history.back()') }

  else
    raise 'invalid modal_action specified'
  end
end
