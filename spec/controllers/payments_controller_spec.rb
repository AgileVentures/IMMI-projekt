require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:user) { create(:user) }

  describe 'routing' do
    it 'routes POST /anvandare/:user_id/betalning/:type to payment#create' do
      expect(post: '/anvandare/1/betalning/member_fee')
        .to route_to(controller: 'payments', action: 'create',
                     user_id: '1', type: Payment::PAYMENT_TYPE_MEMBER)
    end
  end

  describe 'POST #create' do
    let(:payment_create) do
      post :create, params: { user_id: user.id, type: Payment::PAYMENT_TYPE_MEMBER }
    end

    it 'handles exception if payment cannot be saved' do
      allow(HipsService).to receive(:create_order).and_return({}) # force exception

      # Cannot test 'rescue' action directly so need to confirm side effects
      expect{ payment_create }.to_not change(Payment, :count)

      expect(flash[:alert]).to eq ["#{I18n.t('payments.create.something_wrong')}"]
    end
  end
end
