class PaymentsController < ApplicationController
  require 'hips'

  def create
    payment_type = params[:type]
    user_id = params[:user_id]

    @payment = Payment.create(payment_type: payment_type,
                              user_id: user_id,
                              status: 'created')

    success_url = payment_url(user_id: user_id, id: @payment.id)
    error_url   = payment_error_url(user_id: user_id, id: @payment.id)

    hips_order = HipsService.create_order(@payment.id,
                                          user_id,
                                          session.id,
                                          payment_type,
                                          success_url,
                                          error_url)
    @hips_id = hips_order['id']
    @payment.hips_id = @hips_id
    @payment.status = hips_order['status']
    @payment.save

  rescue RuntimeError, HTTParty::Error => exc
    @payment.destroy if @payment.persisted?

    log_hips_activity('create order', nil, @hips_id, exc)

    helpers.flash_message(:alert,
      'Something went wrong - please contact system administrator')

    redirect_back fallback_location: root_path
  end

  def update
    payment = Payment.find(params[:id])
    hips_order = HipsService.get_order(payment.hips_id)

    if payment.hips_id != hips_order['id']
      raise "HIPS ID (#{hips_order['id']}) != SHF HIPS id (#{payment.hips_id})"
    end

    payment.status = hips_order['status']
    payment.save

    # Confirm success status
    if hips_order['status'] == 'successful'
      helpers.flash_message(:notice, 'Payment successfully processed - thank you!')
    else
      helpers.flash_message(:alert,
        'Payment status uncertain - please contact system administrator')
    end

  rescue RuntimeError, HTTParty::Error => exc
    log_hips_activity('update payment', payment&.id, hips_order&['id'], exc)

    helpers.flash_message(:alert,
      'Something went wrong - please contact system administrator')

  ensure
    # Redirect to user account page (when it exists)
    redirect_to root_path
  end

  def error
    payment = Payment.find(params[:id])
    hips_order = HipsService.get_order(payment.hips_id)

    payment.status = hips_order['status']
    payment.save

  rescue RuntimeError, HTTParty::Error => exc
  ensure
    log_hips_activity('order create error', payment&.id, hips_order&['id'], exc)

    helpers.flash_message(:alert,
      'There was an error in processing your payment - please contact system administrator')

    # Redirect to user account page (when it exists)
    redirect_to root_path
  end

  private

  def log_hips_activity(activity, payment_id, hips_id, exc)
    ActivityLogger.open(HIPS_LOG, 'HIPS_API', activity, false) do |log|
      log.record('error', "Payment ID: #{payment_id}") if payment_id
      log.record('error', "HIPS ID: #{hips_id}") if hips_id
      log.record('error', "Exception class: #{exc.class}") if exc
      log.record('error', "Exception message: #{exc.message}") if exc
    end
  end
end
