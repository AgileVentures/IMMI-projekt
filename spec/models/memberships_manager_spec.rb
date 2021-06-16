require 'rails_helper'

RSpec.describe MembershipsManager, type: :model do
  let(:user) { build(:user) }
  let(:mock_membership) { double(Membership) }
  let(:mock_memberships) { double(ActiveRecord::Relation) }

  before(:each) do
    allow(user).to receive(:memberships).and_return(mock_memberships)
  end


  it '.expires_soon_status is :expires_soon' do
    expect(described_class.expires_soon_status).to eq(:expires_soon)
  end


  it '.informational_statuses is the list containing expires soon status' do
    expect(described_class.informational_statuses).to match_array([described_class.expires_soon_status])
  end


  describe '.most_recent_membership_method' do
    it 'is :last_day ' do
      expect(described_class.most_recent_membership_method).to eq :last_day
    end
  end

  describe '.days_can_renew_early' do
    it 'gets the value from AppConfiguration and returns the number of days (Duration)' do
      expect( AdminOnly::AppConfiguration.config_to_use).to receive(:payment_too_soon_days)
                                                              .and_return(7)
      expect(described_class.days_can_renew_early).to eq 7.days
    end
  end


  describe '.grace_period' do
    it 'gets the value from AppConfiguration and returns the number of days (Duration)' do
      expect( AdminOnly::AppConfiguration.config_to_use).to receive(:membership_expired_grace_period_duration)
                                                              .and_return(ActiveSupport::Duration.parse('P90D'))
      expect(described_class.grace_period.iso8601).to eq 'P90D'
    end
  end


  describe '.is_expiring_soon_amount' do

    it 'gets the value from the AppConfiguration' do
      expect( AdminOnly::AppConfiguration.config_to_use).to receive(:membership_expiring_soon_days)
                                                              .and_return(42)
      expect(described_class.is_expiring_soon_amount).to eq 42.days
    end
  end


  describe '.create_archived_memberships_for' do
    it 'creates an ArchivedMembership for every Membership for a user' do
      expect(ArchivedMembership.count).to eq(0)
      member = create(:member)
      create(:membership, user: member, last_day: member.membership_expire_date - 1.day)
      expect { described_class.create_archived_memberships_for(member) }.to change(ArchivedMembership, :count).by(2)
    end
  end


  describe '.get_next_membership_number' do
    pending
  end


  describe 'most_recent_membership' do
    let(:membership_ending_2021_12_31) {  build(:membership, last_day: Date.new(2021, 12, 31)) }

    before(:each) do
      allow(mock_memberships).to receive(:empty?).and_return(false)
      allow(mock_memberships).to receive(:order).and_return(mock_memberships)
      allow(mock_memberships).to receive(:last).and_return(membership_ending_2021_12_31)
    end

    it "gets the user's memberships" do
      expect(user).to receive(:memberships).and_return(mock_memberships)
      subject.most_recent_membership(user)
    end

    it 'returns nil if there are no memberships for the user' do
      allow(mock_memberships).to receive(:empty?).and_return(true)
      expect(subject.most_recent_membership(user)).to be_nil
    end

    it 'sorts them with the most_recent_membership method' do
      allow(subject).to receive(:most_recent_membership_method)
                          .and_return(:some_method)
      expect(mock_memberships).to receive(:order).with(:some_method)
      subject.most_recent_membership(user)
    end

    it 'returns the last one' do
      expect(mock_memberships).to receive(:last).and_return(membership_ending_2021_12_31)
      expect(subject.most_recent_membership(user)).to eq membership_ending_2021_12_31
    end
  end


  describe 'most_recent_membership_method' do
    it 'calls the class method' do
      expect(described_class).to receive(:most_recent_membership_method)
      subject.most_recent_membership_method
    end
  end


  describe 'most_recent_membership_first_day' do
    it 'nil if there are no memberships' do
      allow(subject).to receive(:most_recent_membership).and_return(nil)
      expect(subject.most_recent_membership_first_day(user)).to be_nil
    end

    it 'is the first day for the most recent membership' do
      expect(mock_membership).to receive(:first_day).and_return(Date.current - 3)
      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)
      expect(subject.most_recent_membership_first_day(user)).to eq(Date.current - 3)
    end

  end

  describe 'most_recent_membership_last_day' do
    it 'is the last day for the most recent membership' do
      expect(mock_membership).to receive(:last_day).and_return(Date.current + 2)
      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)
      expect(subject.most_recent_membership_last_day(user)).to eq(Date.current + 2)
    end

    it 'nil if the user has no memberships' do
      allow(subject).to receive(:most_recent_membership).and_return(nil)
      expect(subject.most_recent_membership_last_day(user)).to be_nil
    end
  end


  describe 'has_membership_on?' do

    it 'false if the given date is nil' do
      expect(subject.has_membership_on?(user, nil)).to be_falsey
    end

    it 'false if the given user is nil' do
      expect(subject.has_membership_on?(nil, Date.current)).to be_falsey
    end


    context 'given user is not nil and given date is not nil' do

      it 'calls Membership.for_user_covering_date to get any memberships that covered that date' do
        allow(mock_memberships).to receive(:exists?)
        expect(Membership).to receive(:for_user_covering_date).and_return(mock_memberships)
        subject.has_membership_on?(user, Date.current)
      end

      it 'returns the value of .exists? for the records that Membership.for_user_covering_date returns' do
        allow(Membership).to receive(:for_user_covering_date).and_return(mock_memberships)
        expect(mock_memberships).to receive(:exists?).and_return(true)
        subject.has_membership_on?(user, Date.current)
      end
    end
  end


  describe 'membership_on' do

    it 'nil if the given date is nil' do
      expect(subject.membership_on(build(:user), nil)).to be_nil
    end

    it 'nil if the given user is nil' do
      expect(subject.membership_on(nil, Date.current)).to be_nil
    end

    context 'given user is not nil and given date is not nil' do
      context 'a membership exists for the given date' do
        it 'calls Membership.for_user_covering_date to get the oldest membership that includes that date' do
          expect(Membership).to receive(:for_user_covering_date)
                                  .with(user, Date.current)
                                  .and_return(mock_memberships)
          allow(mock_memberships).to receive(:first).and_return(mock_membership)
          expect(subject.membership_on(user, Date.current)).to eq(mock_membership)
        end
      end

      it 'nil if no membership exists for the given date' do
        expect(Membership).to receive(:for_user_covering_date)
                                .with(user, Date.current)
                                .and_return(nil)

        expect(subject.membership_on(user, Date.current)).to be_nil
      end
    end
  end


  describe 'membership_in_grace_period?' do

    it 'false if user has no memberships' do
      expect(subject).to receive(:most_recent_membership).and_return(nil)
      expect(subject.membership_in_grace_period?(user)).to be_falsey
    end

    it 'default given date is Date.current' do
      allow(subject).to receive(:grace_period).and_return(2.days)
      allow(mock_membership).to receive(:last_day).and_return(Date.current - 1)

      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)
      expect(subject.membership_in_grace_period?(user)).to be_truthy
    end

    it 'default is to use the most recent membership' do
      allow(subject).to receive(:grace_period).and_return(2.days)
      allow(mock_membership).to receive(:last_day).and_return(Date.current  - 1)

      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)
      expect(subject.membership_in_grace_period?(user)).to be_truthy
    end

    it 'returns date_in_grace_period?(given date, last day of most recent membership)' do
      given_date = Date.current + 1
      membership_last_day = Date.current

      allow(subject).to receive(:grace_period).and_return(2.days)
      allow(mock_membership).to receive(:last_day).and_return(membership_last_day)
      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)

      expect(subject).to receive(:date_in_grace_period?)
                           .with(given_date, last_day: membership_last_day)
      subject.membership_in_grace_period?(user, given_date)
    end
  end


  describe 'date_after_grace_period_end?' do
    before(:each) do
      allow(subject).to receive(:grace_period).and_return(3)
      allow(mock_membership).to receive(:last_day).and_return(Date.current - 2)
    end

    it 'false if membership is nil' do
      expect(subject.date_after_grace_period_end?(user, Date.current, membership: nil)).to be_falsey
    end

    it 'true if the given date is after (>) (the membership last day + the grace period days)' do
      expect(subject.date_after_grace_period_end?(user,
                                                  Date.current + 4,
                                                  membership: mock_membership)).to be_truthy
    end

    it 'false if the given date is on or before (the membership last day + the grace period days)' do
      expect(subject.date_after_grace_period_end?(user,
                                                  Date.current,
                                                  membership: mock_membership)).to be_falsey
      expect(subject.date_after_grace_period_end?(user,
                                                  Date.current + 1,
                                                  membership: mock_membership)).to be_falsey
    end

    it 'default date is Date.current' do
      expect(subject.date_after_grace_period_end?(user,
                                                  membership: mock_membership)).to be_falsey
    end

    it 'default membership is the most recent membership for the user' do
      allow(subject).to receive(:most_recent_membership)
                          .and_return(mock_membership)
      expect(subject.date_after_grace_period_end?(user,
                                                  Date.current + 4)).to be_truthy
    end
  end

  describe 'date_in_grace_period?' do
    let(:grace_period) { 2.days }
    before(:each) do
      allow(subject).to receive(:grace_period).and_return(grace_period)
    end

    it 'default date is Date.current' do
      expect(subject.date_in_grace_period?(last_day: Date.current - 1,
                                           grace_days: 2)).to be_truthy
      expect(subject.date_in_grace_period?(last_day: Date.current - 1,
                                           grace_days: 1)).to be_truthy
      expect(subject.date_in_grace_period?(last_day: Date.current - 2,
                                           grace_days: 1)).to be_falsey
    end

    it 'default last day is Date.current' do
      expect(subject.date_in_grace_period?(Date.current + 1.day,
                                           grace_days: 0)).to be_falsey
      expect(subject.date_in_grace_period?(Date.current + 1,
                                           grace_days: 1)).to be_truthy
    end

    it 'default grace days is grace_period' do
      expect(subject).to receive(:grace_period).and_return(3.days)
      expect(subject.date_in_grace_period?(Date.current + 3.days,
                                           last_day: Date.current)).to be_truthy
    end


    it 'false if given_date is before the first day' do
      expect(subject.date_in_grace_period?(Date.current,
                                           last_day: Date.current - 1,
                                           grace_days: 0)).to be_falsey
    end

    context 'given date is on or after the first day of the time period' do

      it 'false if the given date is before the last day' do
        expect(subject.date_in_grace_period?(Date.current - 1.day,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_falsey
      end

      it 'false if the given date is the last day' do
        expect(subject.date_in_grace_period?(Date.current,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_falsey
      end

      it 'true if the given date is before (last day + grace period)' do
        expect(subject.date_in_grace_period?(Date.current + grace_period - 1.day,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_truthy
      end

      it 'true if this date is the last day of the grace period (== first day + grace period)' do
        expect(subject.date_in_grace_period?(Date.current + grace_period,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_truthy
      end

      it 'false if the given date is after (last day + grace period)' do
        expect(subject.date_in_grace_period?(Date.current + grace_period + 1.day,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_falsey
      end
    end
  end


  describe 'days_can_renew_early' do
    it 'calls the class method' do
      expect(described_class).to receive(:days_can_renew_early)
      subject.days_can_renew_early
    end
  end


  describe 'grace_period' do
    it 'calls the class method' do
      expect(described_class).to receive(:grace_period)
      subject.grace_period
    end
  end


  describe 'today_is_valid_renewal_date?' do
    it 'calls valid_renewal_date? for Date.current' do
      expect(subject).to receive(:valid_renewal_date?).with(user, Date.current)
      subject.today_is_valid_renewal_date?(user)
    end
  end

  describe 'valid_renewal_date?' do

    it 'false if the user has no memberships' do
      allow(subject).to receive(:has_membership_on?).with(user, anything)
                                                    .and_return(false)
      expect(subject.valid_renewal_date?(user, Date.current)).to be_falsey
    end

    context 'user has memberships' do
      let(:membership_last_day) { Date.current }
      let(:num_days_can_renew_early) { 3 }

      before(:each) do
        allow(subject).to receive(:days_can_renew_early).and_return(num_days_can_renew_early)
        allow(subject).to receive(:most_recent_membership_last_day).and_return(membership_last_day)
      end

      it 'default date is Date.current' do
        allow(subject).to receive(:has_membership_on?).and_return(true)
        expect(subject.valid_renewal_date?(user)).to be_truthy
      end

      context 'given date is on or before the last day of the current membership' do
        before(:each) { allow(subject).to receive(:has_membership_on?).and_return(true) }

        it 'true if given date is the last day' do
          expect(subject.valid_renewal_date?(user, membership_last_day)).to be_truthy
        end

        it 'true if given date == (last day - days it is too early to renew)' do
          expect(subject.valid_renewal_date?(user, membership_last_day - num_days_can_renew_early)).to be_truthy
        end

        it 'true if given date after (last day - days it is too early to renew)' do
          expect(subject.valid_renewal_date?(user, membership_last_day - num_days_can_renew_early + 1)).to be_truthy
        end

        it 'false if the date is before (expiry - days it is too early to renew)' do
          expect(subject.valid_renewal_date?(user, membership_last_day - num_days_can_renew_early - 1)).to be_falsey
        end
      end

      context 'given date is after the last day of the current membership' do

        context 'is in the grace period for renewal' do
          it 'is result of whether the membership is in the grace period' do
            allow(user).to receive(:in_grace_period?).and_return(true)

            given_date = Date.current + 1
            expect(subject).to receive(:membership_in_grace_period?)
                                 .with(user, given_date)
                                 .and_return(true)
            expect(subject.valid_renewal_date?(user, given_date)).to be_truthy
          end
        end

        it 'false if is a former member (no longer in the grace period for renewal)' do
          allow(user).to receive(:in_grace_period?).and_return(false)
          allow(user).to receive(:former_member?).and_return(true)

          expect(subject).not_to receive(:most_recent_membership_last_day)
                                   .with(user)
          expect(subject).not_to receive(:membership_in_grace_period?)
                               .with(user, anything)
          expect(subject.valid_renewal_date?(user, Date.current + 1)).to be_falsey
        end
      end
    end
  end


  describe 'expires_soon?' do
    let(:u) { build(:member_with_expiration_date, expiration_date: Date.current + 5.days) }

    context 'user is a current_member' do
      before(:each) do
        allow(u).to receive(:current_member?).and_return(true)
        allow(subject).to receive(:most_recent_membership).with(u)
                             .and_return(mock_membership)
        allow(mock_membership).to receive(:last_day).and_return(Date.current + 1.month)
      end

      it 'gets the amount of time that defines "expiring soon"' do
        expect(described_class).to receive(:is_expiring_soon_amount).and_return(1.day)
        subject.expires_soon?(u)
      end

      it 'false if the last day is more than (is_expiring_soon_amount) after Date.current' do
        expect(described_class).to receive(:is_expiring_soon_amount).and_return(1.week)
        expect(subject.expires_soon?(u)).to be_falsey
      end

      it 'true if the last day is exactly (is_expiring_soon_amount) before Date.current' do
        allow(mock_membership).to receive(:last_day).and_return(Date.current + 1.week)
        expect(described_class).to receive(:is_expiring_soon_amount).and_return(1.week)
        expect(subject.expires_soon?(u)).to be_truthy
      end

      it 'true if the last day is less than (is_expiring_soon_amount) before Date.current' do
        allow(mock_membership).to receive(:last_day).and_return(Date.current + 1.week - 1.day)
        expect(described_class).to receive(:is_expiring_soon_amount).and_return(1.week)
        expect(subject.expires_soon?(u)).to be_truthy
      end
    end

    it 'false if user is not a current_member' do
      allow(u).to receive(:current_member?).and_return(false)
      expect(subject.expires_soon?(u)).to be_falsey
    end

    it 'default membership is the most recent one' do
      allow(u).to receive(:current_member?).and_return(true)

      expect(subject).to receive(:most_recent_membership)
                          .with(u)
                          .and_return(mock_membership)
      expect(mock_membership).to receive(:last_day)
                                  .and_return(Date.current + 5.days)
      subject.expires_soon?(u)
    end

    it 'can provide a specific membership to check' do
      allow(u).to receive(:current_member?).and_return(true)
      allow(described_class).to receive(:is_expiring_soon_amount).and_return(6.days)

      expect(mock_membership).to receive(:last_day)
                                   .and_return(Date.current + 5.days)
      expect(subject.expires_soon?(u, mock_membership)).to be_truthy
    end
  end

end
