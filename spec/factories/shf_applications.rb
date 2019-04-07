FactoryBot.define do

  sequence(:cat_name_seq, "Business Category", 1) { |name, num| "#{name} #{num}" }

  factory :shf_application do
    phone_number { 'MyString' }
    contact_email { 'MyString@email.com' }
    state { :new }
    when_approved { nil }

    updated_at { Time.zone.now }

    association :user

    # This association is required.  Also, there should only be *one* instance
    # of each file-delivery method in the DB.  Create an instance only if none present.
    file_delivery_method { AdminOnly::FileDeliveryMethod.first ||
                           association(:file_delivery_method) }

    file_delivery_selection_date { Date.current }                    

    trait :legacy_application do
      file_delivery_method { nil }
      to_create { |instance| instance.save(validate: false) }
    end

    trait :accepted do
      state { :accepted }
      when_approved { Time.zone.now }
    end

    trait :rejected do
      state { :rejected }
      when_approved { nil }
    end

    transient do
      num_categories { 1 }
      category_name { "Business Category" }
      company_number { nil }
      create_company { true }
    end

    after(:build) do |shf_app, evaluator|

      if evaluator.num_categories == 1
        shf_app.business_categories << build(:business_category, name: evaluator.category_name)
      else
        evaluator.num_categories.times do |cat_num|
          shf_app.business_categories << build(:business_category, name: "#{evaluator.category_name} #{cat_num + 1}")
        end
      end

      company = nil
      if evaluator.company_number
        company = Company.find_by(company_number: evaluator.company_number)
        unless company
          company = FactoryBot.create(:company, company_number: evaluator.company_number)
        end
      elsif evaluator.create_company
        company = FactoryBot.create(:company)
      end
      shf_app.companies << company if company
    end

  end
end
