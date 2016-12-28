FactoryGirl.define do
  factory :company do
    name 'SomeCompany'
    company_number '0000000000'
    phone_number '123123123'
    email 'thiscompany@example.com'
    street '123 1st Street'
    post_code '00000'
    city 'Hundborg'
    region
    website 'http://www.example.com'
  end
end
