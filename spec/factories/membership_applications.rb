FactoryGirl.define do

  sequence(:cat_name_seq, 'Business Category', 1) { |name, num| "#{name} #{num}" }

  factory :membership_application do
    first_name 'Firstname'
    last_name 'Lastname'
    company_number '5562252998'
    phone_number 'MyString'
    contact_email 'MyString@email.com'
    association :user
    association :company

    transient do
      num_categories 1
      category_name 'Business Category'
    end

    after(:build) do |membership_app, evaluator|

      if evaluator.num_categories == 1
        membership_app.business_categories << build(:business_category, name: evaluator.category_name)
      else
        evaluator.num_categories.times do |cat_num|
          membership_app.business_categories << build(:business_category, name: "#{evaluator.category_name} #{cat_num + 1}")
        end
      end
    end


  end
end
