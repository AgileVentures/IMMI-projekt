FactoryBot.define do
  sequence(:email) { |num| "email_#{num}@random.com" }

  factory :user do
    first_name 'Firstname'
    last_name 'Lastname'
    email
    password 'my_password'
    admin false
    member false
    member_photo do
      File.new("#{Rails.root}/spec/fixtures/member_photos/photo_unavailable.png")
    end

    transient do
      company_number 5712213304
    end

    factory :user_without_first_and_lastname do

      after(:create) do |user|
        user.first_name = nil
        user.last_name = nil
        user.save(validate: false)
      end
    end

    factory :user_with_membership_app do

      after(:create) do |user, evaluator|
        create_list(:shf_application, 1, user: user, contact_email: evaluator.email, company_number: evaluator.company_number)
      end
    end

    factory :member_with_membership_app do

      member true

      transient do
        company_number 5562728336
      end

      after(:create) do |user, evaluator|
        create_list(:shf_application, 1, :accepted, user: user,
                    contact_email: evaluator.email,
                    company_number:  evaluator.company_number)
      end
    end
  end

end
