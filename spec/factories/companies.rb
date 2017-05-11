FactoryGirl.define do
  factory :company do
    name 'SomeCompany'
    company_number '0000000000'
    phone_number '123123123'
    email 'thiscompany@example.com'
    website 'http://www.example.com'
    address_visibility 'street_address'

    transient do
      num_addresses 1
      street_address nil
      region nil
      city nil
      post_code nil
    end

    after(:build) do |company, evaluator|

      evaluator.num_addresses.times do |addr_num|
        a = build(:company_address, addressable: company, street_address: "Hundforetagarevägen #{addr_num + 1}")
        a.street_address = evaluator.street_address if evaluator.street_address
        a.city = evaluator.city if evaluator.city
        a.post_code = evaluator.post_code if evaluator.post_code
        a.region = evaluator.region if evaluator.region

        company.addresses << a
      end
    end

  end

end
