require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(build(:payment)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :user_id }
    it { is_expected.to have_db_column :company_id }
    it { is_expected.to have_db_column :payment_type }
    it { is_expected.to have_db_column :status }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :company }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :payment_type }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_inclusion_of(:status)
                            .in_array(Payment::ORDER_PAYMENT_STATUS.values) }
  end

  describe '.order_to_payment_status' do
    it "returns payment status 'created' for nil order status" do
      expect(described_class.order_to_payment_status(nil)).to eq 'skapad'
    end

    it "returns payment status 'pending' for 'pending' order status" do
      expect(described_class.order_to_payment_status('pending')).to eq 'avvaktan'
    end

    it "returns payment status 'paid' for 'successful' order status" do
      expect(described_class.order_to_payment_status('successful')).to eq 'betald'
    end

    it "returns payment status 'expired' for 'expired' order status" do
      expect(described_class.order_to_payment_status('expired')).to eq 'utgånget'
    end

    it "returns payment status 'awaiting payments' for 'awaiting_payments' order status" do
      expect(described_class.order_to_payment_status('awaiting_payments'))
        .to eq 'Väntar på betalning'
    end

  end
end
