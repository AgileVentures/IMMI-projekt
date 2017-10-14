class PaymentsController < ApplicationController
  require 'hips'

  def new
    payment_type = params[:type]
    user_id = params[:user_id]

    @payment = Payment.create(payment_type: payment_type,
                              user_id: user_id,
                              status: Payment::STATUS[:NEW])

    hips_order = HipsService.create_order(@payment.id,
                                          user_id,
                                          session.id,
                                          payment_type)

    @hips_id = hips_order['id']

    @payment.hips_id = @hips_id
    @payment.status = Payment::STATUS[:PENDING] if hips_order['status'] == 'pending'
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

end
