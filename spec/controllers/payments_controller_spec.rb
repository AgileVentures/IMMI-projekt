require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do

  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:company) { create(:company) }
  let(:payment) { create(:payment, user: user1, company: company) }
  let(:application) { create(:shf_application, user: user1, companies: [company]) }

  let(:klarna_order) do
    { 'order_id' => 'klarna_order_id',
      'order_amount' => 30000,
      'captured_amount' => 30000,
      'locale' => 'sv-se'
    }
  end

  let(:uncaptured_order) do
    { 'order_id' => 'klarna_order_id',
      'order_amount' => 30000,
      'captured_amount' => 0,
      'locale' => 'sv-se'
    }
  end

  describe 'routing' do
    it 'routes POST /anvandare/:user_id/betalning/:type to payments#create' do
      expect(post: '/anvandare/1/betalning/member_fee')
        .to route_to(controller: 'payments', action: 'create',
                     user_id: '1', type: Payment::PAYMENT_TYPE_MEMBER)

      expect(post: '/anvandare/1/betalning/branding_fee?company_id=1')
        .to route_to(controller: 'payments', action: 'create',
                     user_id: '1', company_id: '1',
                     type: Payment::PAYMENT_TYPE_BRANDING)
    end

    it 'routes GET /anvandare/:user_id/betalning/:id?klarna_id=klarna_order_id to payments#confirmation' do
      expect(get: '/anvandare/1/betalning/1?klarna_id=klarna_order_id')
        .to route_to(controller: 'payments', action: 'confirmation',
                     user_id: '1', id: '1', klarna_id: 'klarna_order_id')
    end

    it 'routes POST /anvandare/betalning/klarna_push?id=1&klarna_id=klarna_order_id to payments#klarna_push' do
      expect(post: '/anvandare/betalning/klarna_push?id=1&klarna_id=klarna_order_id')
        .to route_to(controller: 'payments', action: 'klarna_push',
                     id: '1', klarna_id: 'klarna_order_id')
    end

    it 'routes POST /anvandare/betalning/webhook to payments#webhook' do
      # Legacy HIPS payment status update - remove later
      expect(post: '/anvandare/betalning/webhook')
        .to route_to(controller: 'payments', action: 'webhook')
    end
  end

  describe 'POST #create' do
    let(:request) do
      post :create, params: { user_id: user1.id, type: Payment::PAYMENT_TYPE_MEMBER }
    end

    it 'creates payment' do
      sign_in user1

      allow(KlarnaService).to receive(:create_order).and_return(uncaptured_order)
      expect(subject).to receive(:log_klarna_activity)

      expect{ request }.to change(Payment, :count).by(1)
    end

    it 'handles exception if payment cannot be saved' do
      sign_in user1

      allow(KlarnaService).to receive(:create_order).and_return({}) # force exception

      # Cannot test 'rescue' action directly so need to confirm side effects

      expect(SHFNotifySlack).to receive(:failure_notification)
                                    .with('PaymentsController#create',
                                          text: 'Ett fel uppstod: Klarna måste anges')

      expect{ request }.to_not change(Payment, :count)

      flash_msg = I18n.t('payments.create.something_wrong',
                         admin_email: ENV['SHF_REPLY_TO_EMAIL'])

      expect(flash[:alert]).to eq [flash_msg]
    end

    it 'rejects unauthorized access' do
      sign_in user2
      request

      expect(response).to have_http_status(302)
      expect(response.redirect_url).to eq root_url
      expect(flash[:alert]).to eq "#{I18n.t('errors.not_permitted')}"
    end

  end

  describe 'GET #confirmation' do
    let(:request) do
      get :confirmation, params: { id: payment.id, user_id: user1.id,
                                    klarna_id: klarna_order['order_id'],
                                    disable_language_change: true }
    end
    let(:request_no_id) do
      get :confirmation, params: { id: payment.id, user_id: user1.id,
                                    disable_language_change: true }
    end

    it 'raises exception if no klarna order id' do
      # Cannot test 'rescue' action directly so need to confirm side effects

      expect(SHFNotifySlack).to receive(:failure_notification)
                                    .with('PaymentsController#confirmation',
                                          text: 'No Klarna order ID')
      expect(subject).to receive(:log_klarna_activity)

      request_no_id

      flash_msg = I18n.t('payments.create.something_wrong',
                         admin_email: ENV['SHF_REPLY_TO_EMAIL'])
      expect(flash[:alert]).to eq [flash_msg]
    end

    it 'processes order: update payment status, send ack and order capture to klarna' do
      expect(subject).to receive(:handle_order_confirmation)
                         .and_call_original
                         .with(klarna_order['order_id'], payment.id.to_s)

      expect(KlarnaService).to receive(:get_checkout_order).and_return(uncaptured_order)
      expect(KlarnaService).to receive(:acknowledge_order)
      expect(Payment).to receive(:order_to_payment_status)
                     .and_return(Payment::ORDER_PAYMENT_STATUS['checkout_complete'])
      expect(KlarnaService).to receive(:capture_order)
      expect(subject).to receive(:log_klarna_activity)

      payment.update_attribute(:status, Payment::PENDING)

      expect{ request }.to change{ payment.reload.status }.from(Payment::PENDING)
                                                          .to(Payment::SUCCESSFUL)
    end

  end

  describe 'POST #klarna_push' do

    let(:request) do
      post :klarna_push, params: { id: payment.id, klarna_id: klarna_order['order_id'] }
    end

    it 'does nothing if order already captured (paid)' do
      expect(KlarnaService).to receive(:get_order).and_return(klarna_order)
      expect(subject).not_to receive(:handle_order_confirmation)
      request
    end

    it 'processes order: update payment status, send ack and order capture to klarna' do
      expect(KlarnaService).to receive(:get_order).and_return(uncaptured_order)

      expect(subject).to receive(:handle_order_confirmation)
                         .and_call_original
                         .with(klarna_order['order_id'], payment.id.to_s)

      expect(KlarnaService).to receive(:get_checkout_order).and_return(uncaptured_order)
      expect(KlarnaService).to receive(:acknowledge_order)
      expect(Payment).to receive(:order_to_payment_status)
                     .and_return(Payment::ORDER_PAYMENT_STATUS['checkout_complete'])
      expect(KlarnaService).to receive(:capture_order)

      payment.update_attribute(:status, Payment::PENDING)

      expect{ request }.to change{ payment.reload.status }.from(Payment::PENDING)
                                                          .to(Payment::SUCCESSFUL)
    end
  end

end
