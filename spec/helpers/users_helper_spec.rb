require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  let!(:user) { create(:user) }
  let(:right_now) { Time.now }
  let(:yesterday) { Time.now - 1.day - 2.minutes }

  describe '#most_recent_login_time' do

    it 'returns nil if the user has never logged in' do
      expect(helper.most_recent_login_time(user)).to be_nil
    end

    it 'returns the current_sign_in_at time if current_sign_in_at is not nil' do
      u = user
      u.update(current_sign_in_at: right_now)
      expect(helper.most_recent_login_time(u)).to eq(right_now)
    end

    it 'returns the current_sign_in_at if it is not nil and there was a last_sign_in_at' do
      u = user
      u.update(current_sign_in_at: right_now, last_sign_in_at: yesterday)
      expect(helper.most_recent_login_time(u)).to eq(right_now)
    end

    it 'returns the last_sign_in_at time if current_sign_in_at is nil' do
      u = user
      u.update(last_sign_in_at: yesterday)
      expect(helper.most_recent_login_time(u)).to eq(yesterday)
    end

  end

  describe '#pay_member_fee_link' do
    let(:user) { create(:user) }
    let(:app)  { create(:membership_application, state: :waiting_for_payment) }
    let(:expected_path) do
      payments_path(user_id: user.id, type: Payment::PAYMENT_TYPE_MEMBER)
    end

    it 'returns nil is user is not enabled to pay fee' do
      expect(pay_member_fee_link(user)).to be_nil
    end

    it 'returns pay-fee link if a member' do
      user.member = true
      expect(pay_member_fee_link(user)).to match expected_path
    end

    it 'returns pay-fee link if user has app in "waiting_for_payment" state' do
      user.membership_applications << app
      user.save
      expect(pay_member_fee_link(user)).to match expected_path
    end
  end


end
