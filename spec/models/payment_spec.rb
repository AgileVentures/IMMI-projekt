require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:success) { Payment::ORDER_PAYMENT_STATUS['successful'] }
  let(:created) { Payment::ORDER_PAYMENT_STATUS[nil] }

  let(:member_pymt1) do
    create(:payment, status: success, expire_date: Time.zone.today + 1.day)
  end
  let(:member_pymt2) do
    create(:payment, status: created, expire_date: Time.zone.today + 1.year)
  end
  let(:member_pymt3) do
    create(:payment, status: success, expire_date: Time.zone.today + 1.year)
  end
  let(:member_pymt4) do
    create(:payment, status: success, expire_date: Time.zone.today - 1.day)
  end

  let(:brand_pymt1) do
    create(:payment, status: success, expire_date: Time.zone.today + 1.day,
           payment_type: Payment::PAYMENT_TYPE_BRANDING)
  end
  let(:brand_pymt2) do
    create(:payment, status: created, expire_date: Time.zone.today + 1.year,
           payment_type: Payment::PAYMENT_TYPE_BRANDING)
  end
  let(:brand_pymt3) do
    create(:payment, status: success, expire_date: Time.zone.today + 1.year,
           payment_type: Payment::PAYMENT_TYPE_BRANDING)
  end

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
    it { is_expected.to have_db_column :start_date }
    it { is_expected.to have_db_column :expire_date }
    it { is_expected.to have_db_column :notes }
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
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :expire_date }
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

  describe 'scope: completed' do

    it 'returns all completed payments' do
      expect(Payment.completed).to contain_exactly(member_pymt3, member_pymt1)
    end
  end

  describe 'scope: Payment::PAYMENT_TYPE_MEMBER' do

    it 'returns all member fee payments' do
      expect(Payment.send(Payment::PAYMENT_TYPE_MEMBER))
        .to contain_exactly(member_pymt3, member_pymt2, member_pymt1)
    end
  end

  describe 'scope: Payment::PAYMENT_TYPE_BRANDING' do

    it 'returns all branding fee payments' do
      expect(Payment.send(Payment::PAYMENT_TYPE_BRANDING))
        .to contain_exactly(brand_pymt3, brand_pymt2, brand_pymt1)
    end
  end

  describe 'scope: unexpired' do
    it 'returns all unexpired payments' do
      expect(Payment.unexpired)
        .to contain_exactly(member_pymt1, member_pymt2, member_pymt3,
                            brand_pymt1, brand_pymt2, brand_pymt3)
    end
  end
end
