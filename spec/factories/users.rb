FactoryBot.define do
  sequence(:email) { |num| "email_#{num}@random.com" }

  factory :user do
    first_name { 'Firstname' }
    last_name { 'Lastname' }
    email
    password { 'my_password' }
    admin { false }
    member { false }
    short_proof_of_membership_url { nil }
    member_photo {nil}
    date_membership_packet_sent { nil }
    sign_in_count { 0 }
    current_sign_in_at { nil }
    last_sign_in_at { nil }
    created_at { DateTime.now.utc }
    updated_at { DateTime.now.utc }

    factory :admin do
      admin { true }
    end


    factory :user_without_first_and_lastname do

      after(:create) do |user|
        user.first_name = nil
        user.last_name = nil
        user.save(validate: false)
      end
    end

    trait :with_member_photo do
      member_photo do
        File.new("#{Rails.root}/spec/fixtures/member_photos/photo_unavailable.png")
      end
    end


    factory :user_with_membership_app do

      after(:create) do |user, evaluator|
        create_list(:shf_application, 1, user: user, contact_email: evaluator.email) # FIXME this should not be a list. Fix tests that use this
      end
    end

    factory :member_with_membership_app do

      member { true }

      transient do
        company_number { 5562728336 }
      end

      after(:create) do |user, evaluator|
        create_list(:shf_application, 1, :accepted, user: user,
                    company_number: evaluator.company_number,
                    contact_email: evaluator.email) # FIXME this should not be a list. Fix tests that use this
      end

    end


    # create a payment for the member with the given expiration date
    # ex:  create(:member_with_expiration_date, expiration_date: Date.new(2018, 6, 24))
    #  Note: this does not create any UserChecklists for the member. That
    #   can be done separately.
    #
    factory :member_with_expiration_date do

      member { true }

      transient do
        expiration_date { Date.current }
      end

      after(:create) do | member, evaluator |

        create(:shf_application, :accepted, user: member)

        create(:membership_fee_payment, user: member,
               start_date: evaluator.expiration_date - 364,
               expire_date: evaluator.expiration_date)
      end
    end

  end

end
