FactoryGirl.define do

  sequence(:cat_name_seq, "Business Category", 1) { |name, num| "#{name} #{num}" }

  factory :membership_application do
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

    after(:build) do |membership_app, evaluator|

      if evaluator.num_categories == 1
        membership_app.business_categories << build(:business_category, name: evaluator.category_name)
      else
        evaluator.num_categories.times do |cat_num|
          membership_app.business_categories << build(:business_category, name: "#{evaluator.category_name} #{cat_num + 1}")
        end
      end

      if (evaluator.state) && evaluator.state.to_sym == :accepted
        membership_app.state = :accepted

        membership_app.user.member = true

        company = Company.find_by(company_number: evaluator.company_number)
        unless company
          company = FactoryGirl.create(:company, company_number: evaluator.company_number)
        end
        membership_app.company = company
      end
    end


  end
end
