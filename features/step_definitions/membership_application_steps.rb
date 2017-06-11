And(/^the following applications exist:$/) do |table|
 table.hashes.each do |hash|
   attributes = hash.except('user_email', 'categories')
   user = User.find_by(email: hash[:user_email])
    if hash['state'] == 'accepted' || hash['state'] == 'rejected'
     company = Company.find_by(company_number: hash['company_number'])
     unless company
       company = FactoryGirl.create(:company, company_number: hash['company_number'])
     end
   end
   ma = FactoryGirl.create(:membership_application,
                            attributes.merge(user: user,
                            company: company,
                            contact_email: hash['user_email']))
   ma.state = hash['state'].to_sym if hash.has_key?('state')
   if hash['categories']
     categories = []
     for category_name in hash['categories'].split(/\s*,\s*/)
       categories << BusinessCategory.find_by_name(category_name)
     end
     ma.business_categories = categories
   end
 end
end

And(/^the following simple applications exist:$/) do |table|
  table.hashes.each do |hash|
    ma = FactoryGirl.build(:membership_application,
                           first_name: 'Fred',
                           last_name: 'Flintstone',
                           company_number: hash['company_number'],
                           contact_email: hash['user_email'],
                           state: hash['state'])
    ma.save(validate: false)
  end
end



And(/^I navigate to the edit page for "([^"]*)"$/) do |first_name|
  membership_application = MembershipApplication.find_by(first_name: first_name)
  visit path_with_locale(edit_membership_application_path(membership_application))
end

Given(/^I am on "([^"]*)" application page$/) do |first_name|
  membership = MembershipApplication.find_by(first_name: first_name)
  visit path_with_locale(membership_application_path(membership))
end

Given(/^I am on the list applications page$/) do
  locale_path = path_with_locale(membership_applications_path)
  visit locale_path
end
