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
    membership_status { 'not_a_member' }

    factory :user_with_ethical_guidelines_checklist do
      after(:create) do |user, _evaluator|
        create(:membership_guidelines_master_checklist ) unless AdminOnly::MasterChecklist.latest_membership_guideline_master
        AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(user)
      end
    end

    factory :admin do
      admin { true }
    end


    factory :user_without_first_and_lastname do

      after(:build) do |user|
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

      transient do
        company_number { nil }
        application_status { :new }
      end

      after(:build) do |user, evaluator|
        # TODO should be a list in prep for when we implement applicants can have more than 1 ShfApplication
        create_list(:shf_application, 1,
                    user: user,
                    state: evaluator.application_status,
                    contact_email: evaluator.email,
                    company_number: evaluator.company_number)
      end
    end


    # Create a Membership for the user
    #   and create a membership payment for the member
    # Can specify the first_day or last_day of the membership
    #
    #   ex:  create(:member_with_expiration_date, expiration_date: Date.new(2018, 6, 24))
    factory :member do
      member { true }

      transient do
        company_number { 5562728336 }
        first_day { nil }
        last_day { nil }
        expiration_date { nil }
        has_uploaded_docs { true } # Do they have uploaded documents for the current membership term?
        contact_email { email }
      end

      after(:create) do |member, evaluator|

        create_list(:shf_application, 1, :accepted, user: member,
                    company_number: evaluator.company_number,
                    contact_email: evaluator.contact_email)

        if evaluator.first_day.nil?
          # in case expiration_date was used. TODO switch these all to use first_day and last_day
          given_last_day = !!evaluator.last_day ? evaluator.last_day : evaluator.expiration_date

          if given_last_day.nil?
            actual_first_day = Date.current
            actual_last_day = Membership.last_day_from_first(actual_first_day)
          else
            actual_last_day = !!evaluator.last_day ? evaluator.last_day : evaluator.expiration_date
            actual_first_day = Membership.first_day_from_last(actual_last_day)
          end
        else
          actual_first_day = evaluator.first_day
          actual_last_day = Membership.last_day_from_first(actual_first_day)
        end

        Membership.create(user: member,
                          first_day: actual_first_day,
                          last_day: actual_last_day)
        member.membership_status = 'current_member' if MembershipsManager.new.has_membership_on?(member, Date.current)
        create(:membership_fee_payment, user: member,
               start_date: actual_first_day,
               expire_date: actual_last_day)

        create(:membership_guidelines_master_checklist ) unless AdminOnly::MasterChecklist.latest_membership_guideline_master
        AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(member)

        # must use the '&' below in case the membership_guidelines_list_for method is stubbed
        UserChecklistManager.membership_guidelines_list_for(member)&.set_complete_including_children

        # uploaded files
        if evaluator.has_uploaded_docs
          uploaded_file = create(:uploaded_file, :txt, user: member)
          member.uploaded_files << uploaded_file
        end

      end

      # member_with_membership_app should be replaced with just 'member'
      factory :member_with_membership_app do
      end

      # member_with_expiration_date should be replaced with just 'member'
      factory :member_with_expiration_date do
        # transient do
        #   expiration_date { Date.current }
        # end
      end
    end

  end
end
