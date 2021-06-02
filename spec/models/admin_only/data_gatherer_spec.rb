require 'rails_helper'

# Note:  Most of these specs are actually *integration* and *feature* specifications:
#         because they test that lots of _data_ is correct in the system via the
#         set up of the data.
#        It requires that quite complete data be set up: payments for companies
#        for membership with applications, applications for users in different states,
#        etc.
#        To do the testing for "recent" items, a history of information must be
#        created so that there are users, members, applications, companies,
#        and payments in different _states_ and with different _dates_.
#
#        This helps to test the entire system in a comprehensive way.  It
#        really exercises the data that we store in the system by creating so
#        many variations.
#
#        Being so complete does make this RSpec take time to run.
#

RSpec.describe AdminOnly::DataGatherer do

  include DataCreationHelper

  # ---------------------------------------------


  let(:subject) { AdminOnly::DataGatherer.new }

  let!(:last_year) { Time.zone.now - 13.months }
  let!(:months_ago) { Time.zone.now - 5.months }
  let!(:not_recent) { Time.zone.now - 8.days }
  let!(:recent) { Time.zone.now - 6.days }

  let(:create_apps_now) { create_apps_in_states }


  # ---------------------------
  # Instance methods
  # ---------------------------


  # ---------------------------
  # public methods

  it "days_ago_list returns the predefined (hardcoded) list of number of days to look backwards for 'recent' data " do

    expect(subject.days_ago_list).to eq [7, 14, 30, 90, 120, 180, 270, 366]

  end


  describe "timeframe  the number of days since today to fetch data" do

    it "default value = DEFAULT_NUM_PAST_DAYS" do
      expect(subject.timeframe).to eq 7
    end

  end


  describe "timeframe=  triggers a refresh_data; can only be set to a number that is in the list of days_ago_list" do

    it "nil, empty string, 'blorf', and a Class will all raise ArgumentError 'timeframe value must be in the days_ago_list'" do
      [nil, '', 'blorf', Class].each do |bad_argument|
        expect { subject.timeframe = bad_argument }.to raise_exception ArgumentError, 'timeframe value must be in the days_ago_list'
      end
    end

    it "can only be set to a value that is in days_ago_list " do
      expect { subject.timeframe = 2 }.to raise_exception ArgumentError, 'timeframe value must be in the days_ago_list'
    end

    it "can be set to any of the values in days_ago_list" do
      subject.days_ago_list.each do |d|
        subject.timeframe = d
        expect(subject.timeframe).to eq d
      end
    end
  end

  describe 'counts' do

    let!(:create_last_years_apps) { create_apps_in_states(create_date: last_year) }

    let!(:create_months_ago_apps) { create_apps_in_states(create_date: months_ago) }

    let!(:create_8_days_ago_apps) { create_apps_in_states(create_date: not_recent) }

    let!(:create_recent_apps) { create_apps_in_states(create_date: recent) }

    it 'timeframe change triggers a data refresh data' do

      recent_app_state_counts = subject.recent_app_state_counts
      expect(recent_app_state_counts[:new]).to eq 1
      expect(recent_app_state_counts[:under_review]).to eq 2
      expect(recent_app_state_counts[:waiting_for_applicant]).to eq 1
      expect(recent_app_state_counts[:ready_for_review]).to eq 2
      expect(recent_app_state_counts[:accepted]).to eq 1
      expect(recent_app_state_counts[:rejected]).to eq 2

      subject.timeframe = 30

      recent_app_state_counts = subject.recent_app_state_counts
      expect(recent_app_state_counts[:new]).to eq 2
      expect(recent_app_state_counts[:under_review]).to eq 4
      expect(recent_app_state_counts[:waiting_for_applicant]).to eq 2
      expect(recent_app_state_counts[:ready_for_review]).to eq 4
      expect(recent_app_state_counts[:accepted]).to eq 2
      expect(recent_app_state_counts[:rejected]).to eq 4
    end

    context "recent_app_state_counts = application states for the current timeframe (= 'recent')" do

      it "recent application state counts are correct for default 'recent' (7 days)" do

        # verify that our data is constructed properly
        app_state_counts = subject.shf_apps_state_counts

        expect(app_state_counts[:new]).to eq(1 * 4)
        expect(app_state_counts[:under_review]).to eq(2 * 4)
        expect(app_state_counts[:waiting_for_applicant]).to eq(1 * 4)
        expect(app_state_counts[:ready_for_review]).to eq(2 * 4)
        expect(app_state_counts[:accepted]).to eq(1 * 4)
        expect(app_state_counts[:rejected]).to eq(2 * 4)


        recent_app_state_counts = subject.recent_app_state_counts
        expect(recent_app_state_counts[:new]).to eq 1
        expect(recent_app_state_counts[:under_review]).to eq 2
        expect(recent_app_state_counts[:waiting_for_applicant]).to eq 1
        expect(recent_app_state_counts[:ready_for_review]).to eq 2
        expect(recent_app_state_counts[:accepted]).to eq 1
        expect(recent_app_state_counts[:rejected]).to eq 2

      end

      it "recent application state counts are correct, then change the timeframe and they are updated and correct" do

        subject.timeframe = 30

        recent_app_state_counts = subject.recent_app_state_counts
        expect(recent_app_state_counts[:new]).to eq 2
        expect(recent_app_state_counts[:under_review]).to eq 4
        expect(recent_app_state_counts[:waiting_for_applicant]).to eq 2
        expect(recent_app_state_counts[:ready_for_review]).to eq 4
        expect(recent_app_state_counts[:accepted]).to eq 2
        expect(recent_app_state_counts[:rejected]).to eq 4
      end
    end

    context 'recent_shf_apps for the current timeframe ' do

      it "recent_shf_apps is correct for default 'recent' (7 days)" do

        expect(subject.recent_shf_apps.count).to eq 9
      end

      it "change the timeframe and it is updated and correct" do

        subject.timeframe = 30

        expect(subject.recent_shf_apps.count).to eq 18
      end
    end

  end


  describe "total_members  the  number of current (good standing) members in the db" do

    it '0 users in the system' do
      expect(subject.total_members).to eq 0
    end

    it 'some users are members, some are not' do

      3.times { create(:user) }
      4.times { create(:member_with_membership_app) }

      expect(subject.total_members).to eq 4

    end

  end


  describe "shf_apps_state_counts gets the totals for every application state" do

    it '0 apps in the system' do
      app_state_counts = subject.shf_apps_state_counts
      expect(subject.shf_apps_state_counts).not_to be_empty
      app_state_counts.each do |_k, v|
        expect(v).to eq 0
      end
    end

    it 'apps in each of the the different states' do

      create_apps_now

      app_state_counts = subject.shf_apps_state_counts
      expect(subject.shf_apps_state_counts).not_to be_empty
      expect(app_state_counts[:new]).to eq 1
      expect(app_state_counts[:under_review]).to eq 2
      expect(app_state_counts[:waiting_for_applicant]).to eq 1
      expect(app_state_counts[:ready_for_review]).to eq 2
      expect(app_state_counts[:accepted]).to eq 1
      expect(app_state_counts[:rejected]).to eq 2

    end

  end


  describe "apps_without_uploads = the total number of apps that are not open, that have 0 files uploaded/attached" do

    it '0 apps in the system' do
      expect(subject.apps_without_uploads.count).to eq 0
    end

    it 'some apps with uploads, some without' do

      # create apps in each state so we're sure to test them all (9 apps total; 6 'open' applications)
      # add uploaded files to some of them (6 with uploaded files.  2 'open' applications with uploaded files)

      create_apps_now

      new_apps = ShfApplication.in_state(:new)
      add_uploaded_file(new_apps.first)

      under_review_apps = ShfApplication.in_state(:under_review)
      add_uploaded_file(under_review_apps.first)

      waiting_apps = ShfApplication.in_state(:waiting_for_applicant)
      add_uploaded_file(waiting_apps.first)

      ready_apps = ShfApplication.in_state(:ready_for_review)
      add_uploaded_file(ready_apps.first)

      accepted_apps = ShfApplication.in_state(:accepted)
      add_uploaded_file(accepted_apps.first)

      rejected_apps = ShfApplication.in_state(:rejected)
      add_uploaded_file(rejected_apps.first)


      expect(subject.apps_without_uploads.count).to eq 2
    end
  end


  describe "apps_approved_member_fee_not_paid  = number of approved members without a membership fee paid for the current membership term" do

    it "0 shf apps" do
      expect(subject.apps_approved_member_fee_not_paid.count).to eq 0
    end

    it "some members, some lapsed members, some not paid" do

      # In the grace period: they are overdue to renew
      4.times { create(:member, last_day: Date.current - 3.years, membership_status: :in_grace_period) }

      3.times { create(:member) }

      # approved applicants that have not paid:
      2.times { create(:user_with_membership_app, application_status: :accepted) }

      expect(subject.apps_approved_member_fee_not_paid.count).to eq 6
    end

  end


  describe "companies_branding_not_paid = companies with the branding fee not paid for the current term" do

    it '0 companies' do
      expect(subject.companies_branding_not_paid.count).to eq 0
    end


    it 'numbers are correct for some paid, some expired, some not paid' do
      # 3 paid and not expired:
      create_co_and_payment('0000000000', Time.zone.today + 1.year)
      create_co_and_payment('5562252998', Time.zone.today + 1.year)
      create_co_and_payment('2120000142', Time.zone.today + 1.year)

      # 1 paid but expired:
      create_co_and_payment('4268582063', Time.zone.today - 1.day)

      # 3 not paid:
      create(:company, company_number: '8356502446')
      create(:company, company_number: '8423893877')
      create(:company, company_number: '9267816362')

      expect(subject.companies_branding_not_paid.count).to eq 4

    end

  end


  describe "companies_info_not_completed  companies that have 'incomplete' information" do

    it '0 companies' do
      expect(subject.companies_info_not_completed.count).to eq 0
    end

    it 'some companies are complete, some are not ' do
      # incomplete = no name or region
      create(:company, company_number: '0000000000')
      create(:company, company_number: '5562252998')
      create(:company, company_number: '8356502446', name: '')
      create(:company, company_number: '8423893877', name: '')
      create(:company, company_number: '9267816362', name: '')

      expect(subject.companies_info_not_completed.count).to eq 3
    end

  end


  describe 'recent information' do


    describe "recent_payments = all payments in the current timeframe (= 'recent')" do

      let(:time_now) { Time.current }
      let(:num_payments_this_month) { 1 }

      let!(:create_two_years_of_payments_num_is_month_number) do
        2.times do |years_ago|

          12.times do |months_ago|
            create_date = time_now - years_ago.years - months_ago.months

            create_member_with_member_and_branding_payments_expiring(create_date + 1.year, payment_create_date: create_date)
          end
        end
      end

      it "recent payments are correct for default 'recent' (7 days)" do

        recent_payments = subject.recent_payments

        expect(recent_payments[Payment::PAYMENT_TYPE_MEMBER.to_sym].count)
            .to eq num_payments_this_month
        expect(recent_payments[Payment::PAYMENT_TYPE_BRANDING.to_sym].count)
            .to eq num_payments_this_month
      end


      it "recent payments are correct; change the timeframe and the recent payments info is updated and correct" do

        recent_payments = subject.recent_payments

        expect(recent_payments[Payment::PAYMENT_TYPE_MEMBER.to_sym].count)
            .to eq num_payments_this_month
        expect(recent_payments[Payment::PAYMENT_TYPE_BRANDING.to_sym].count)
            .to eq num_payments_this_month

        subject.timeframe = 120 # 4 months ago

        #  Note by the time the query runs to get the data, some time has elapsed.
        #  So any payments created exactly 1 month after the initial time (now)
        #  are now > 1 month old by the amount of time that has elapsed.
        #  Thus they will *not* show up in the '30 days ago' query;
        #  they will show up in the '60 days ago' query (or any query more than 30 days ago)

        recent_payments = subject.recent_payments

        expect(recent_payments[Payment::PAYMENT_TYPE_MEMBER.to_sym].count).to eq 4
        expect(recent_payments[Payment::PAYMENT_TYPE_BRANDING.to_sym].count).to eq 4

      end

    end


    describe "get_recent_data(timeframe_start, timeframe_end) reads only the shf_apps and financial data in the current timeframe" do

      it "starting with no data, then add data; will get added (recent) data with default timeframe (7 days)" do

        expect(subject.total_members).to eq 0

        app_state_counts = subject.shf_apps_state_counts
        app_state_counts.each do |_k, v|
          expect(v).to eq 0
        end

        expect(subject.apps_without_uploads.count).to eq 0
        expect(subject.apps_approved_member_fee_not_paid.count).to eq 0
        expect(subject.companies_branding_not_paid.count).to eq 0
        expect(subject.companies_info_not_completed.count).to eq 0

        recent_app_state_counts = subject.shf_apps_state_counts
        recent_app_state_counts.each do |_k, v|
          expect(v).to eq 0
        end

        expect(subject.recent_payments[Payment::PAYMENT_TYPE_MEMBER.to_sym].count).to eq 0
        expect(subject.recent_payments[Payment::PAYMENT_TYPE_BRANDING.to_sym].count).to eq 0

        create_member_with_member_and_branding_payments_expiring

        subject.get_recent_data

        expect(subject.recent_shf_apps.count).to eq 1

        recent_payments = subject.recent_payments
        expect(recent_payments[Payment::PAYMENT_TYPE_MEMBER.to_sym].count).to eq 1
        expect(recent_payments[Payment::PAYMENT_TYPE_BRANDING.to_sym].count).to eq 1
      end


      it "custom time-frame: start= 5 months ago, end: now" do

        now = Time.zone.now

        six_months_ago = now - 6.months
        create_member_with_member_and_branding_payments_expiring(six_months_ago + 1.year, payment_create_date: six_months_ago)

        five_months_ago = now - 5.months
        create_member_with_member_and_branding_payments_expiring(five_months_ago + 1.year, payment_create_date: five_months_ago)
        create_member_with_member_and_branding_payments_expiring(five_months_ago + 1.year, payment_create_date: five_months_ago)

        four_months_ago = now - 4.months
        create_member_with_member_and_branding_payments_expiring(four_months_ago + 1.year, payment_create_date: four_months_ago)
        create_member_with_member_and_branding_payments_expiring(four_months_ago + 1.year, payment_create_date: four_months_ago)
        create_member_with_member_and_branding_payments_expiring(four_months_ago + 1.year, payment_create_date: four_months_ago)

        three_months_ago = now - 3.months
        create_member_with_member_and_branding_payments_expiring(three_months_ago + 1.year, payment_create_date: three_months_ago)
        create_member_with_member_and_branding_payments_expiring(three_months_ago + 1.year, payment_create_date: three_months_ago)
        create_member_with_member_and_branding_payments_expiring(three_months_ago + 1.year, payment_create_date: three_months_ago)
        create_member_with_member_and_branding_payments_expiring(three_months_ago + 1.year, payment_create_date: three_months_ago)

        two_months_ago = now - 2.months
        create_member_with_member_and_branding_payments_expiring(two_months_ago + 1.year, payment_create_date: two_months_ago)
        create_member_with_member_and_branding_payments_expiring(two_months_ago + 1.year, payment_create_date: two_months_ago)
        create_member_with_member_and_branding_payments_expiring(two_months_ago + 1.year, payment_create_date: two_months_ago)
        create_member_with_member_and_branding_payments_expiring(two_months_ago + 1.year, payment_create_date: two_months_ago)
        create_member_with_member_and_branding_payments_expiring(two_months_ago + 1.year, payment_create_date: two_months_ago)

        one_months_ago = now - 1.months
        create_member_with_member_and_branding_payments_expiring(one_months_ago + 1.year, payment_create_date: one_months_ago)
        create_member_with_member_and_branding_payments_expiring(one_months_ago + 1.year, payment_create_date: one_months_ago)
        create_member_with_member_and_branding_payments_expiring(one_months_ago + 1.year, payment_create_date: one_months_ago)
        create_member_with_member_and_branding_payments_expiring(one_months_ago + 1.year, payment_create_date: one_months_ago)
        create_member_with_member_and_branding_payments_expiring(one_months_ago + 1.year, payment_create_date: one_months_ago)
        create_member_with_member_and_branding_payments_expiring(one_months_ago + 1.year, payment_create_date: one_months_ago)

        subject.get_recent_data(five_months_ago, now)

        expect(subject.recent_shf_apps.count).to eq 20

        recent_payments = subject.recent_payments
        expect(recent_payments[Payment::PAYMENT_TYPE_MEMBER.to_sym].count).to eq 20
        expect(recent_payments[Payment::PAYMENT_TYPE_BRANDING.to_sym].count).to eq 20

      end


    end


  end


  # ---------------------------
  # private methods


  describe "refresh_data [private] reloads the data from the db. Can be used to ensure more recent data is fetched" do

    it '@total_members is updated' do
      expect(subject.total_members).to eq 0

      create(:user)
      create(:member_with_membership_app)

      subject.send(:refresh_data)

      expect(subject.total_members).to eq 1
    end


    it '@apps_without_uploads is updated' do

      expect(subject.apps_without_uploads.count).to eq 0

      create(:user_with_membership_app)

      subject.send(:refresh_data)

      expect(subject.apps_without_uploads.count).to eq 1

    end

    it '@apps_approved_member_fee_not_paid is updated' do
      expect(subject.apps_approved_member_fee_not_paid.count).to eq 0

      3.times { create(:shf_application, :accepted) }
      2.times { create(:member) }

      subject.send(:refresh_data)
      expect(subject.apps_approved_member_fee_not_paid.count).to eq 3
    end

    it '@companies_branding_not_paid is updated' do

      expect(subject.companies_branding_not_paid.count).to eq 0

      # 3 paid and not expired:
      create_co_and_payment('0000000000', Time.zone.today + 1.year)
      create_co_and_payment('5562252998', Time.zone.today + 1.year)
      create_co_and_payment('2120000142', Time.zone.today + 1.year)

      # 1 paid but expired:
      create_co_and_payment('4268582063', Time.zone.today - 1.day)

      # 3 not paid:
      create(:company, company_number: '8356502446')
      create(:company, company_number: '8423893877')
      create(:company, company_number: '9267816362')

      subject.send(:refresh_data)
      expect(subject.companies_branding_not_paid.count).to eq 4
    end

    it '@companies_info_not_completed is updated' do

      expect(subject.companies_info_not_completed.count).to eq 0
      # incomplete = no name or region
      create(:company, company_number: '0000000000')
      create(:company, company_number: '5562252998')
      create(:company, company_number: '8356502446', name: '')
      create(:company, company_number: '8423893877', name: '')
      create(:company, company_number: '9267816362', name: '')

      subject.send(:refresh_data)
      expect(subject.companies_info_not_completed.count).to eq 3
    end

    it 'get_data_for_past_days is called so all that info is also updated' do
      expect(subject).to receive(:get_data_for_past_days)
      subject.send(:refresh_data)
    end
  end


  describe 'private methods - recent information' do

    let!(:start_date) { Time.zone.local(2018, 01, 01, 00, 00, 00) }
    let!(:before_start_date) { Time.zone.local(2017, 12, 31, 23, 59, 59) }
    let!(:after_start_date) { Time.zone.local(2018, 01, 01, 00, 00, 01) }

    let!(:end_date) { Time.zone.local(2018, 02, 01, 00, 00, 00) }
    let!(:before_end_date) { Time.zone.local(2018, 01, 31, 23, 59, 59) }
    let!(:after_end_date) { Time.zone.local(2018, 02, 01, 00, 00, 01) }


    describe "get_data_for_past_days(start_date, end_date) [private] fetches all data starting at start_date, up to and including end_date" do

      around(:each) do |example|
        Timecop.freeze(start_date)
        example.run
        Timecop.return
      end

      it "default number of days is 7" do
        expect(subject).to receive(:get_recent_data).with(Time.zone.now - 7.days, Time.zone.now)
        expect(subject.send(:get_data_for_past_days))
      end

      it "can set to 3 days in the past" do
        expect(subject).to receive(:get_recent_data).with(Time.zone.now - 3.days, Time.zone.now)
        expect(subject.send(:get_data_for_past_days, 3))
      end

    end


    describe "get_recent_shf_apps(start_date, end_date) [private] gets all applications updated in the curren timeframe" do

      it "no recent apps in the timeframe" do
        expect(subject.send(:get_recent_shf_apps, start_date, end_date)).to be_empty
      end

      it '1 app done today and no others' do
        user = create(:user_with_membership_app)
        expect(subject.send(:get_recent_shf_apps, Time.zone.now - 1.day, Time.zone.now)).to contain_exactly(user.shf_application)
      end

      it '1 app today, 1 at the end of the timeframe (to the second), 1 in the middle of the timeframe' do

        _updated_before_start_date = create(:shf_application, updated_at: before_start_date)
        updated_after_start_date = create(:shf_application, updated_at: after_start_date)
        updated_on_end_date = create(:shf_application, updated_at: end_date)
        _updated_after_end_date = create(:shf_application, updated_at: after_end_date)

        expect(subject.send(:get_recent_shf_apps, start_date, end_date)).to contain_exactly(updated_after_start_date,
                                                                                            updated_on_end_date)
      end

    end


    describe "get_recent_financial_info(start_date, end_date) [private] gets all financial-related info in the current timeframe" do

      it "no recent apps in the timeframe" do
        actual_payments = subject.send(:get_recent_financial_info, start_date, end_date)
        actual_payments.each do |_each_type_k, each_type_v|
          expect(each_type_v).to be_empty
        end
      end

      it '1 payment done today and no others' do

        member = create_member_with_member_and_branding_payments_expiring
        actual_payments = subject.send(:get_recent_financial_info, Time.zone.now - 1.day, Time.zone.now)

        actual_payments.each do |each_type_k, each_type_v|
          member_payments = member.payments.select { |p| p.payment_type == each_type_k.to_s }
          expect(each_type_v).to match_array(member_payments)
        end
      end

      it '1 payment today, 1 at the end of the timeframe (to the second), 1 in the middle of the timeframe' do

        _updated_before_start_date = create_member_with_member_and_branding_payments_expiring(payment_create_date: before_start_date)
        updated_after_start_date = create_member_with_member_and_branding_payments_expiring(payment_create_date: after_start_date)
        updated_on_end_date = create_member_with_member_and_branding_payments_expiring(payment_create_date: end_date)
        _updated_after_end_date = create_member_with_member_and_branding_payments_expiring(payment_create_date: after_end_date)

        actual_payments = subject.send(:get_recent_financial_info, start_date, end_date)

        actual_payments.each do |each_type_k, each_type_v|
          member_payments = updated_after_start_date.payments.select { |p| p.payment_type == each_type_k.to_s } +
              updated_on_end_date.payments.select { |p| p.payment_type == each_type_k.to_s }
          expect(each_type_v).to match_array(member_payments)
        end

      end

    end


  end

end # RSpec.describe 'AdminOnly::DataGatherer'
