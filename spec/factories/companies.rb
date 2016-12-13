FactoryGirl.define do
  factory :company do
    name 'SomeCompany'
    company_number '0000000000'
    phone_number '123123123'
    email 'thiscompany@example.com'
    street '123 1st Street'
    post_code '00000'
    city 'Hundborg'
    region 'D'
    website 'http://www.example.com'

    transient do
      num_categories 0
      category_name 'Business Category'
    end

    after(:create) do |company, evaluator|

      if evaluator.num_categories == 1
        company.business_categories << create(:business_category, name: evaluator.category_name)
      else
        evaluator.num_categories.times do |cat_num|
          company.business_categories << create(:business_category, name: "#{evaluator.category_name} #{cat_num + 1}")
        end
      end
    end


  end
end
