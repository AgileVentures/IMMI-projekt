FactoryBot.define do

  factory :payment do
    user
    company { nil }
    payment_type { Payment::PAYMENT_TYPE_MEMBER }
    status { Payment::CREATED }
    start_date { Time.zone.today }
    expire_date { Time.zone.today + 1.year - 1.day }
    klarna_id { 'none' }
    payment_processor { 'Klarna' }
    notes { nil }
    updated_at { Time.zone.now }
  end


  factory :membership_fee_payment, parent: :payment do
    payment_type { Payment::PAYMENT_TYPE_MEMBER }
    status { Payment::SUCCESSFUL }
  end

  factory :expired_membership_fee_payment, parent: :membership_fee_payment do
    expire_date { Time.zone.yesterday }
    start_date { expire_date - 1.year }
  end

  factory :h_branding_fee_payment, parent: :payment do
    payment_type { Payment::PAYMENT_TYPE_BRANDING }
    status { Payment::SUCCESSFUL }
  end

  factory :expired_h_branding_fee_payment, parent: :h_branding_fee_payment do
    expire_date { Time.zone.yesterday }
    start_date { expire_date - 1.year }
  end

  trait :successful do
    status { Payment::SUCCESSFUL }
  end

  trait :pending do
    status { Payment::PENDING }
  end

  # This means that the HIPS status is 'expired', not the payment term status
  trait :expired do
    status { Payment::EXPIRED }
  end

  trait :awaiting_payment do
    status { Payment::AWAITING_PAYMENTS }
  end

end
