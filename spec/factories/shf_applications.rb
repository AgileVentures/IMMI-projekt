FactoryBot.define do

  sequence(:cat_name_seq, "Business Category", 1) { |name, num| "#{name} #{num}" }

  factory :shf_application do
    company_number '5562252998'
    phone_number 'MyString'
    contact_email 'MyString@email.com'
    state :new

    association :user

    trait :accepted do
      state :accepted
    end

    trait :rejected do
      state :rejected
    end

    transient do
      num_categories 0
      category_name "Business Category"
    end

    after(:build) do |shf_app, evaluator|

      if evaluator.num_categories == 1
        shf_app.business_categories << build(:business_category, name: evaluator.category_name)
      else
        evaluator.num_categories.times do |cat_num|
          shf_app.business_categories << build(:business_category, name: "#{evaluator.category_name} #{cat_num + 1}")
        end
      end

      if (evaluator.state) && evaluator.state.to_sym == :accepted
        shf_app.state = :accepted

        company = Company.find_by(company_number: evaluator.company_number)
        unless company
          company = FactoryBot.create(:company, company_number: evaluator.company_number)
        end
        shf_app.companies << company
      end
    end


  end
end
