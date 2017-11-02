Given(/^the following payments exist$/) do |table|
  table.hashes.each do |payment|
    user_email = payment.delete('user_email')
    user = User.find_by_email(user_email)

    FactoryGirl.create(:payment, payment.merge(user: user))
  end
end

Then(/^I click on the pay membership button$/) do
  # We don't want to access HIPS in testing. Emulate controller actions:
  start_date, expire_date = User.next_payment_dates(@user.id)

  @payment = Payment.create(payment_type: Payment::PAYMENT_TYPE_MEMBER,
                            user_id: @user.id,
                            status: Payment.order_to_payment_status('pending'),
                            start_date: start_date,
                            expire_date: expire_date,
                            hips_id: 'none')
end

And(/^I complete the payment$/) do
  # Emulate webhook and success controller actions
  @payment.status = Payment.order_to_payment_status('successful')
  @payment.save
  visit payment_success_path(user_id: @user.id, id: @payment.id)
end

And(/^I abandon the payment$/) do
  #noop
end

And(/^I incur an error in payment processing$/) do
  visit payment_error_path(user_id: @user.id, id: @payment.id)
end
