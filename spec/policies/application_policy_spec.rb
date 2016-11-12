require 'rails_helper'

RSpec.describe ApplicationPolicy do

  let(:user_1) { create(:user, email: 'user_1@random.com') }
  let(:user_2) { create(:user, email: 'user_2@random.com') }
  let(:application) { create(:membership_application,
                             user: user_1) }

  describe 'For Creator of MembershipApplication' do
    subject { described_class.new(user_1, application) }

    it { is_expected.to permit_action :show }
    it { is_expected.to permit_action :edit }
  end

  describe 'For other users of MembershipApplication' do
    subject { described_class.new(user_2, application) }

    it { is_expected.to forbid_action :show }
    it { is_expected.to forbid_action :edit }
  end
end
