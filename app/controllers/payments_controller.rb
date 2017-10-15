class PaymentsController < ApplicationController
  require 'hips'

  def create
    payment_type = params[:type]
    user_id = params[:user_id]

    @payment = Payment.create(payment_type: payment_type,
                              user_id: user_id,
                              status: 'created')

    success_url = payment_url(user_id: user_id, id: @payment.id)

    hips_order = HipsService.create_order(@payment.id,
                                          user_id,
                                          session.id,
                                          payment_type,
                                          success_url,
                                          root_url)
    @hips_id = hips_order['id']

    @payment.hips_id = @hips_id
    @payment.status = hips_order['status']
    @payment.save

  rescue => e

    ActivityLogger.open('log/HIPS.log', 'HIPS_API', 'create order', false) do |log|
      log.record('error', 'Cannot create payment or HIPS order')
      log.record('error', "Payment ID: #{@payment&.id}")
      log.record('error', "HIPS ID: #{@hips_id if @hips_id}")
      log.record('error', "Exception class: #{e.class}")
      log.record('error', "Exception message: #{e.message}")
    end

    helpers.flash_message(:alert,
      'Something went wrong - please contact system administrator')

    redirect_to(request.referer.present? ? :back : root_path)
  end

  def update
    debugger

    payment = Payment.find(params[:id])
    hips_order = HipsService.get_order(payment.hips_id)

    payment.status = hips_order['status']
    payment.save

    # Confirm success status
    if hips_order['status'] == 'successful'
      helpers.flash_message(:notice, 'Payment successfully processed - thank you!')
    else
      helpers.flash_message(:alert,
        'Payment status uncertain - please contact system administrator')
    end

    # Redirect to user account page (when it exists)
    redirect_to root_path
  end
end
