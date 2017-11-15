Given(/^the following payments exist$/) do |table|
  table.hashes.each do |payment|
    user_email = payment.delete('user_email')
    user = User.find_by_email(user_email)

    FactoryGirl.create(:payment, payment.merge(user: user))
  end
end

And(/^I complete the payment$/) do
  # Emulate webhook payment-update and direct to "success" action
  payment = @user.payments.last # present for member, nil for user

  payment = FactoryGirl.create(:payment, user: @user) unless payment

  start_date, expire_date = User.next_payment_dates(@user.id)
  payment.update!(status: Payment.order_to_payment_status('successful'),
                  start_date: start_date, expire_date: expire_date)

  @user.member = true
  @user.issue_membership_number
  @user.save

  visit payment_success_path(user_id: @user.id, id: payment.id)
end

And(/^I abandon the payment$/) do
  page.evaluate_script('window.history.back()')
end

And(/^I incur an error in payment processing$/) do
  payment = @user.most_recent_payment
  visit payment_error_path(user_id: @user.id, id: payment.id)
end
