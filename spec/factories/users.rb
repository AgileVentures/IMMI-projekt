FactoryGirl.define do
  sequence(:email) { |num| "email_#{num}@random.com" }

  factory :user do
    first_name 'Firstname'
    last_name 'Lastname'
    email
    password 'my_password'
    admin false

    transient do
      company_number 5712213304
    end

    factory :user_with_membership_app do

      after(:create) do |user, evaluator|
        create_list(:membership_application, 1, user: user, contact_email: evaluator.email, company_number: evaluator.company_number)
      end
    end

    factory :user_with_2_membership_apps do

      transient do
        company_number1 5712213304
        company_number2 5562728336
      end

      after(:create) do |user, evaluator|
        create(:membership_application, user: user, contact_email: evaluator.email, company_number: evaluator.company_number1)
        create(:membership_application, user: user, contact_email: evaluator.email, company_number: evaluator.company_number2)
      end

    end

    factory :member_with_membership_app do

      transient do
        company_number 5562728336
      end

      after(:create) do |user, evaluator|
        create_list(:membership_application, 1, :accepted, user: user,
                    contact_email: evaluator.email,
                    company_number:  evaluator.company_number)
      end
    end
  end

end
