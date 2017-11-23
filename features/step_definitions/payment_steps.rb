Given(/^the following payments exist$/) do |table|
  table.hashes.each do |payment|
    user_email = payment.delete('user_email')
    user = User.find_by_email(user_email)

    company_number = payment.delete('company_number')
    company = nil
    company = Company.find_by_company_number(company_number) if company_number

    FactoryGirl.create(:payment, payment.merge(user: user, company: company))
  end
end

And(/^I complete the payment$/) do
  # Emulate webhook payment-update and direct to "success" action
  payment = @user.payments.last # present for member, nil for user

  payment = FactoryGirl.create(:payment, user: @user) unless payment

  start_date, expire_date = User.next_membership_payment_dates(@user.id)
  payment.update!(status: Payment.order_to_payment_status('successful'),
                  start_date: start_date, expire_date: expire_date)

  @user.grant_membership
  @user.save

  visit payment_success_path(user_id: @user.id, id: payment.id)
end

And(/^I complete the branding payment for "([^"]*)"$/) do |company_name|
  # Emulate webhook payment-update and direct to "success" action

  company = Company.find_by_name(company_name)

  payment = company.most_recent_branding_payment

  payment = FactoryGirl.create(:payment, user: @user, company: company,
                               payment_type: Payment::PAYMENT_TYPE_BRANDING) unless payment

  start_date, expire_date = Company.next_branding_payment_dates(company.id)
  payment.update!(status: Payment.order_to_payment_status('successful'),
                  start_date: start_date, expire_date: expire_date)

  visit payment_success_path(user_id: @user.id, id: payment.id)
end

And(/^I abandon the payment$/) do
  page.evaluate_script('window.history.back()')
end

And(/^I incur an error in payment processing$/) do
  payment = @user.most_recent_membership_payment
  visit payment_error_path(user_id: @user.id, id: payment.id)
end

And(/^I incur an error in branding payment processing for "([^"]*)"$/) do |company_name|
  company = Company.find_by_name(company_name)
  payment = company.most_recent_branding_payment
  visit payment_error_path(user_id: @user.id, company_id: company.id, id: payment.id)
end
