FactoryGirl.define do
  factory :payment do
    user
    company nil
    payment_type Payment::PAYMENT_TYPE_MEMBER
    status Payment.order_to_payment_status(nil)
    start_date Date.today
    expire_date Date.today + 1.year - 1.day
    hips_id 'none'
  end
end
