FactoryBot.define do
  factory :company do
    name { 'SomeCompany' }
    company_number do
      org_number = nil

      100.times do
        org_number = OrgNummersGenerator.generate_one

        # stop if number not already used
        break if ! Company.find_by_company_number(org_number) # FIXME this forces interaction with the db. = s.l.o.w.
      end

      org_number
    end
    phone_number { '123123123' }
    email { 'thiscompany@example.com' }
    website { 'http://www.example.com' }
    short_h_brand_url { nil }

    transient do
      num_addresses { 1 }
      street_address { nil }
      region { nil }
      city { nil }
      post_code { nil }
      country { 'Sverige' }
    end

    after(:build) do |company, evaluator|

      evaluator.num_addresses.times do |addr_num|
        a = build(:company_address, addressable: company, street_address: "Hundforetagarevägen #{addr_num + 1}", )
        a.street_address = evaluator.street_address if evaluator.street_address
        a.city = evaluator.city if evaluator.city
        a.post_code = evaluator.post_code if evaluator.post_code
        a.region = evaluator.region if evaluator.region
        a.country = evaluator.country if evaluator.country

        company.addresses << a
      end
    end

  end

end
