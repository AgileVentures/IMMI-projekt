FactoryGirl.define do
  sequence(:email) { |num| "email_#{num}@random.com" }

  factory :user do
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
      after(:create) do |user, evaluator|
        create_list(:membership_application, 2, user: user, contact_email: evaluator.email, company_number: evaluator.company_number)
      end

    end

    factory :member_with_membership_app do

      transient do
        company_number 5562728336
      end

      after(:create) do |user, evaluator|
        user.is_member = true
        create_list(:membership_application, 1, :accepted, user: user,
                    first_name: evaluator.email,
                    contact_email: evaluator.email,
                    company_number:  evaluator.company_number)
      end
    end
  end

end
