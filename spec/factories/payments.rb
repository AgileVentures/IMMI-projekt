FactoryGirl.define do
  factory :payment do
    user
    company nil
    payment_type Payment::PAYMENT_TYPE_MEMBER
    status 'skapad'
    start_date Date.new(2017, 1, 1)
    expire_date Date.new(2017, 12, 31)
  end
end
