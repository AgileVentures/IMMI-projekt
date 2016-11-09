FactoryGirl.define do
  factory :user do
    first_name 'Emma'
    last_name 'Andersson'
    password 'password'
    password_confirmation 'password'
    street 'Storgatan 20'
    postal_code 30247
    city 'Halmstad'
    email 'susanna@immi.nu'
    email_confirmation 'susanna@immi.nu'
  end
end
