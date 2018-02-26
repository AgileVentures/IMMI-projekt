require 'rails_helper'
include ApplicationHelper

RSpec.describe UsersHelper, type: :helper do
  let(:user) { create(:user) }
  let(:right_now) { Time.zone.now }
  let(:yesterday) { Time.zone.now - 1.day - 2.minutes }

  let(:app)  { create(:shf_application, state: :accepted) }
  let(:expected_path) do
    payments_path(user_id: user.id, type: Payment::PAYMENT_TYPE_MEMBER)
  end
  let(:user_payment) do
    create(:payment, user: user, status: Payment::ORDER_PAYMENT_STATUS['successful'])
  end

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

  describe 'pay_member_fee_link' do

    it 'returns nil if user is not enabled to pay fee' do
      expect(pay_member_fee_link(user)).to be_nil
    end

    it 'returns pay-fee link if a member' do
      user.member = true
      expect(pay_member_fee_link(user)).to match expected_path
    end

    it 'returns pay-fee link if user has app in "accepted" state' do
      user.shf_application = app
      user.save
      expect(pay_member_fee_link(user)).to match expected_path
    end
  end

  describe 'paperclip_path' do

    it 'returns relative path if to be rendered via HTML' do
      expect(paperclip_path(user.member_photo, :standard, :html))
        .to eq user.member_photo.url
    end

    it 'returns absolute path if to be rendered within image' do
      expect(paperclip_path(user.member_photo, :standard, :jpg))
        .to eq user.member_photo.path
    end

    it 'returns absolute path to default image if no attached file' do
      user.update(member_photo: nil)
      default_path = Rails.root.join('app', 'assets', 'images',
                                     user.member_photo.url(:standard))

      expect(paperclip_path(user.member_photo, :standard, :jpg))
        .to eq default_path
    end
  end

  describe 'user_has_open_application' do

    it 'returns yes if open app exists' do
      app.update(state: :new)
      user.shf_application = app

      expect(user_has_open_application(user)).to eq I18n.t('yes')
    end

    it 'returns nil otherwise' do
      expect(user_has_open_application(user)).to be_nil
    end
  end
end
