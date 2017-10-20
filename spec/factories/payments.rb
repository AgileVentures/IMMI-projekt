FactoryGirl.define do
  factory :payment do
    user
    company nil
    payment_type 'member_fee'
    status 'skapad'
  end
end
