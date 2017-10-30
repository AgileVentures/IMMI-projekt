FactoryGirl.define do
  factory :payment do
    user
    company nil
    payment_type Payment::PAYMENT_TYPE_MEMBER
    status 'skapad'
  end
end
