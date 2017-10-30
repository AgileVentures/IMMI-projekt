class PaymentsController < ApplicationController
  require 'hips'

  SUCCESSFUL_HIPS_ORDER_EVENT = 'order.successful'

  protect_from_forgery except: :webhook

  def create
    # The user wants to pay a fee (e.g. membership fee)
    payment_type = params[:type]
    user_id = params[:user_id]

    # HIPS will associate the payment with a "merchant reference" - which
    # will be our Payment ID.  We can use this later to fetch the HIPS order.
    @payment = Payment.create(payment_type: payment_type,
                              user_id: user_id,
                              status: Payment.order_to_payment_status(nil))

    # Build data structures for HIPS order
    urls = hips_order_urls(user_id, @payment.id)
    payment_data = { id: @payment.id, type: payment_type, currency: 'SEK' }

    # Invoke HIPS API - returns an order to be used for checkout
    hips_order = HipsService.create_order(user_id,
                                          session.id,
                                          payment_data,
                                          urls)

    # Save payment and render HIPS checkout form
    @hips_id = hips_order['id']
    @payment.hips_id = @hips_id
    @payment.status = Payment.order_to_payment_status(hips_order['status'])
    @payment.save!

  rescue RuntimeError, HTTParty::Error, ActiveRecord::RecordInvalid  => exc
    @payment.destroy if @payment.persisted?

    log_hips_activity('create order', 'error', nil, @hips_id, exc)

    log_hips_activity('create order', 'error', nil, @hips_id, exc.cause)

    helpers.flash_message(:alert, t('.something_wrong'))

    redirect_back fallback_location: root_path
  end

  def webhook
    # This webhook will be called multiple times (7) during the order create and
    # payment process. We are only interested in the "order.successful" event,
    # which indicates successful payment.
    # Later, we can switch to "hooks/webhook_url_on_success" - which will
    # be triggered *only* by the "order.successful" event.
    # (That webhook is not available at this time (October 18, 2017)).

    payload = JSON.parse request.body.read

    return head(:ok) unless payload['event'] == SUCCESSFUL_HIPS_ORDER_EVENT

    resource = HipsService.validate_webhook_origin(payload['jwt'])

    payment_id = resource['merchant_reference']['order_id']
    hips_id    = resource['id']

    payment = Payment.find(payment_id)
    payment.status = Payment.order_to_payment_status(resource['status'])
    payment.save

    log_hips_activity('Webhook', 'info', payment_id, hips_id)

  rescue RuntimeError => exc
    log_hips_activity('Webhook', 'error', payment_id, hips_id, exc)

  ensure
    head :ok
  end

  def success
    helpers.flash_message(:notice, t('.success'))
    redirect_to root_path   # Redirect to user account page (when it exists)
  end

  def error
    helpers.flash_message(:alert, t('.error'))
    redirect_to root_path   # Redirect to user account page (when it exists)
  end

  private

  def log_hips_activity(activity, severity, payment_id, hips_id, exc=nil)
    ActivityLogger.open(HIPS_LOG, 'HIPS_API', activity, false) do |log|
      log.record(severity, "Payment ID: #{payment_id}") if payment_id
      log.record(severity, "HIPS ID: #{hips_id}") if hips_id
      log.record(severity, "Exception class: #{exc.class}") if exc
      log.record(severity, "Exception message: #{exc.message}") if exc
    end
  end

  def hips_order_urls(user_id, payment_id)
    urls = {}
    urls[:success] = payment_success_url(user_id: user_id, id: payment_id)
    urls[:error]   = payment_error_url(user_id: user_id, id: payment_id)
    urls[:webhook] = (SHF_WEBHOOK_HOST || root_url) + payment_webhook_path.sub('/en', '')
    urls
  end
end
