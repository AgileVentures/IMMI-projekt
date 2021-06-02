# Steps for viewing membership status, changing it
#
#

And("my membership expiration date should be {date}") do |date|
  expect(@user.membership_expire_date).to eq date
end


Then("the last day of membership for {capture_string} should be {date}") do |user_email, date|
  user = User.find_by(email: user_email)
  expect(user.membership_expire_date).to eq date
end
