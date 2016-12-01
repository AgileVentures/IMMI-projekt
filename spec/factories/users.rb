FactoryGirl.define do
  sequence(:email) { |num| "email_#{num}@random.com" }

  factory :user do
    email
    password 'my_password'
    admin false
    is_member false
  end
end
