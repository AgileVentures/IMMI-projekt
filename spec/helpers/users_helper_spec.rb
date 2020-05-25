require 'rails_helper'
include ApplicationHelper

RSpec.describe UsersHelper, type: :helper do
  let(:user) { create(:user, :with_member_photo) }
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


  describe 'paperclip_path_str' do

    it 'returns relative path if to be rendered via HTML' do
      expect(paperclip_path_str(user.member_photo, :standard, :html))
        .to eq user.member_photo.url
    end

    it 'returns absolute path if to be rendered within image' do
      expect(paperclip_path_str(user.member_photo, :standard, :jpg))
        .to eq user.member_photo.path
    end

    it 'returns absolute path to default image if no attached file' do
      user.update(member_photo: nil)
      default_path = Rails.root.join('app', 'assets', 'images',
                                     user.member_photo.url(:standard)).to_s

      expect(paperclip_path_str(user.member_photo, :standard, :jpg))
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

  describe '#short_proof_of_membership_url' do
    it 'returns value returned by User#get_short_proof_of_membership_url using generated url' do
      url = proof_of_membership_url(user.id)
      allow(user).to receive(:get_short_proof_of_membership_url).with(url).and_return(url)
      expect(short_proof_of_membership_url(user)).to eq(url)
    end
  end


  describe '#membership_packet_str' do

    let(:i18n_scope) { 'users.show_info_for_admin_only' }


    it 'not empty even if user is not a member' do
      not_a_member = create(:user)
      expect(membership_packet_str(not_a_member)).not_to be_empty
    end

    context 'date_package_sent is nil' do
      it 'says not sent; has no date sent' do
        not_sent_member = create(:member_with_membership_app)
        expect(membership_packet_str(not_sent_member)).to eq("#{t('member_packet', scope: i18n_scope).capitalize} #{t('not_sent', scope: i18n_scope)}")
      end
    end

    context 'date_package_sent not nil' do
      it 'says sent; has the date sent' do
        today = DateTime.current
        sent_member = create(:member_with_membership_app, date_membership_packet_sent: today)
        expect(membership_packet_str(sent_member)).to eq("#{t('member_packet', scope: i18n_scope).capitalize} #{t('sent', scope: i18n_scope)} #{today.to_date}")
      end
    end

  end


  describe '#membership_packet_status_str' do

    let(:i18n_scope) { 'users.show_info_for_admin_only' }

    it 'is t(sent) if the package was sent' do
      expect(membership_packet_status_str(true)).to eq I18n.t('sent', scope: i18n_scope)
    end

    it 'is t(not_sent) if the package was not sent' do
      expect(membership_packet_status_str(false)).to eq I18n.t('not_sent', scope: i18n_scope)
    end

  end


  it 'member_packet_sent_checkbox' do
    expect(member_packet_sent_checkbox(create(:user))).to match(/<input type="checkbox" name="date_membership_packet_sent" id="date_membership_packet_sent" value="false" class="checkbox.membership-packet" data-remote="true" data-method="post" data-url="\/anvandare\/(\d+)\/toggle_membership_package_sent\s*/)
  end
end
