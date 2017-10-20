FactoryGirl.define do
  factory :payment do
    user
    company nil
    payment_type 'member_fee'
    status 'created'
  end
end
