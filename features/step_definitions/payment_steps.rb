Given(/^the following payments exist(?:[:])?$/) do |table|
  table.hashes.each do |payment|
    user_email = payment.delete('user_email')
    company_name = payment.delete('company_name')

    user = User.find_by_email(user_email)

    if company_name
      company = Company.find_by_name(company_name)
    else
      company_number = payment.delete('company_number')
      company = nil
      company = Company.find_by_company_number(company_number) if company_number
    end

    FactoryBot.create(:payment, payment.merge(user: user, company: company))
  end
end


And(/^I complete the membership payment$/) do
  # Emulate webhook payment-update and direct to "success" action

  # NOTE: The "most recent payment" of any type is determined via the
  #       "created_at" attribute. This means that any payments created
  #       in your feature "Background" section should be created with
  #       appropriate dates (using step "Given the date is set to <date>").

  RSpec::Mocks.with_temporary_scope do
    allow(KlarnaService).to receive(:get_checkout_order)
      .and_return({ 'order_amount' => 30000, 'status' => 'checkout_complete' })
    allow(KlarnaService).to receive(:acknowledge_order)
    allow(KlarnaService).to receive(:capture_order)
    allow_any_instance_of(PaymentsController).to receive(:log_klarna_activity)

    start_date, expire_date = User.next_membership_payment_dates(@user.id)

    payment = FactoryBot.create(:payment, user: @user,
                                payment_type: 'member_fee',
                                status: Payment.order_to_payment_status('checkout_incomplete'),
                                start_date: start_date, expire_date: expire_date)

    visit payment_confirmation_path(user_id: @user.id, id: payment.id,
                                    klarna_id: 'klarna_id')
  end
end

And(/^I complete the branding payment for "([^"]*)"$/) do |company_name|
  # Emulate Klarna payment-confirmation and direct to "confirmation" action
  # (see note in step above)

  RSpec::Mocks.with_temporary_scope do
    allow(KlarnaService).to receive(:get_checkout_order)
      .and_return({ 'order_amount' => 30000, 'status' => 'checkout_complete' })
    allow(KlarnaService).to receive(:acknowledge_order)
    allow(KlarnaService).to receive(:capture_order)
    allow_any_instance_of(PaymentsController).to receive(:log_klarna_activity)

    company = Company.find_by_name(company_name)

    start_date, expire_date = Company.next_branding_payment_dates(company.id)

    payment = FactoryBot.create(:payment, user: @user, company: company,
                                payment_type: 'branding_fee',
                                status: Payment.order_to_payment_status('checkout_incomplete'),
                                start_date: start_date, expire_date: expire_date)

    visit payment_confirmation_path(user_id: @user.id, id: payment.id,
                                    klarna_id: 'klarna_id')
  end
end

And(/^I abandon the payment by going back to the previous page$/) do
  #page.evaluate_script('window.history.back()')
  page.go_back
end

And(/^I incur an error in payment processing$/) do
  payment = @user.most_recent_membership_payment
  # if there are no payments, make one so we can show the error page
  unless payment
    user_id = @user.id
    start_date, expire_date = User.next_membership_payment_dates(user_id)
    payment = Payment.create(payment_type: Payment.membership_payment_type,
                              user_id: user_id,
                              company_id: nil,
                              status: Payment.order_to_payment_status(nil),
                              start_date: start_date,
                              expire_date: expire_date)
    payment.save
  end
  visit payment_error_path(user_id: @user.id, id: payment.id)
end
