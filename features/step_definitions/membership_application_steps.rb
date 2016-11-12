And(/^the following applications exist:$/) do |table|
  table.hashes.each do |hash|
    application_attributes = hash.except('user_email')
    user = User.find_by(email: hash[:user_email])
    FactoryGirl.create(:membership_application, application_attributes.merge(user: user))
  end
end