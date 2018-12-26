require 'rails_helper'
require 'email_spec/rspec'
require 'timecop'


LOG_DIR      = 'tmp'
LOG_FILENAME = 'testlog.txt'


# Note that the described class is _not_ an ActiveRecord, so the database is not
# automatically cleaned between examples.

RSpec.describe CompanyEmailAlert, focus:true do

  let(:jan1) { Date.new(2019, 1, 1) }
  let(:jun1) { Date.new(2019, 6, 1) }
  let(:jun6) { Date.new(2019, 6, 6) }

  let(:all_companies) do
    [ create(:company, name: 'company1'),
      create(:company, name: 'company2'),
      create(:company)
    ]
  end

  let(:c1_all_paid) { all_companies.first }

  let(:member1_c1_exp_jun6) do
      shf_accepted_app = create(:shf_application, :accepted, company_number: c1_all_paid.company_number)
      member = shf_accepted_app.user

      create(:membership_fee_payment,
             :successful,
             user:        member,
             company: c1_all_paid,
             start_date:  jun6 - 364,
             expire_date: jun6)
      create(:h_branding_fee_payment,
             :successful,
             user:        member,
             company: c1_all_paid,
             start_date:  jun6 - 364,
             expire_date: jun6)
      member
  end


  let(:c2_2_members) { all_companies.detect{|c| c.name == 'company2'}}

  let(:member1_c2_exp_jun6) do
    shf_accepted_app = create(:shf_application, :accepted, company_number: c2_2_members.company_number)
    member = shf_accepted_app.user

    create(:membership_fee_payment,
           :successful,
           user:        member,
           company: c2_2_members,
           start_date:  jun6 - 364,
           expire_date: jun6)
    member
  end

  let(:member2_c2_exp_jun1) do
    shf_accepted_app = create(:shf_application, :accepted, company_number: c2_2_members.company_number)
    member = shf_accepted_app.user

    create(:membership_fee_payment,
           :successful,
           user:        member,
           company: c2_2_members,
           start_date:  jun1 - 364,
           expire_date: jun1)
    member
  end


  describe '.send_email' do

    let(:filepath) { File.join(Rails.root, LOG_DIR, LOG_FILENAME) }
    let(:log) { ActivityLogger.open(filepath, 'TEST', 'open', false) }


    before(:each) do
      File.delete(filepath) if File.file?(filepath)
    end

    after(:all) do
      tmpfile = File.join(Rails.root, LOG_DIR, LOG_FILENAME)
      File.delete(tmpfile) if File.exist?(tmpfile)
    end


    context 'successful' do

      it 'delivers email to each member and logs each one' do
        member1_c2_exp_jun6
        member2_c2_exp_jun1

        allow(described_class.instance).to receive(:mailer_method).and_return(:h_branding_fee_past_due)

        expect(described_class.instance.mailer_class).to receive(:h_branding_fee_past_due)
            .exactly(c2_2_members.current_members.size).times
            .and_call_original

        described_class.instance.send_email(c2_2_members, log)

        expect(ActionMailer::Base.deliveries.size).to eq(c2_2_members.current_members.size)
        expect(File.read(filepath)).to include("[info] CompanyEmailAlert email sent to user id: #{member1_c2_exp_jun6.id} email: #{member1_c2_exp_jun6.email} company id: #{c2_2_members.id} name: #{c2_2_members.name}.")
        expect(File.read(filepath)).to include("[info] CompanyEmailAlert email sent to user id: #{member2_c2_exp_jun1.id} email: #{member2_c2_exp_jun1.email} company id: #{c2_2_members.id} name: #{c2_2_members.name}.")
      end
    end

    context 'failure' do

      it 'logs the failure info' do
        member1_c2_exp_jun6
        member2_c2_exp_jun1

        allow(described_class.instance).to receive(:mailer_method).and_return(:h_branding_fee_past_due)

        expect(described_class.instance.mailer_class).to receive(:h_branding_fee_past_due)
                                                    .exactly(c2_2_members.current_members.size).times
                                                    .and_return(Net::ProtocolError)

        described_class.instance.send_email(c2_2_members, log)

        expect(ActionMailer::Base.deliveries.size).to eq 0
        expect(File.read(filepath)).to include("[error] CompanyEmailAlert email ATTEMPT FAILED to user id: #{member1_c2_exp_jun6.id} email: #{member1_c2_exp_jun6.email} company id: #{c2_2_members.id} name: #{c2_2_members.name}. undefined method `deliver_now' for Net::ProtocolError:Class Also see for possible info")
        expect(File.read(filepath)).to include("[error] CompanyEmailAlert email ATTEMPT FAILED to user id: #{member2_c2_exp_jun1.id} email: #{member2_c2_exp_jun1.email} company id: #{c2_2_members.id} name: #{c2_2_members.name}.")
      end
    end
  end


  describe '.entities_to_check' do

    it 'returns all companies (Company.all)' do
      # create companies and everything.
      c1 = create(:company, name: 'c1')
     # c2 = create(:company, name: 'c2')
     # c3 = create(:company, name: 'c3')

      NEWLINE = "\n"
      actual = described_class.instance.entities_to_check.to_a
      expect(actual).to match_array([c1]), "\n was: #{actual.map{|c| c.inspect.to_s + NEWLINE } }"
    end
  end


  it '.mail_message sends both company and member as args to the mailer_method' do

    allow(described_class.instance).to receive(:mailer_method).and_return(:h_branding_fee_past_due)

    allow(described_class.instance.mailer_class).to receive(:h_branding_fee_past_due)
        .with(c1_all_paid, member1_c1_exp_jun6)
        .and_return('it worked!')

    expect(described_class.instance.mail_message(c1_all_paid, member1_c1_exp_jun6)).to eq 'it worked!'
  end

  it '.mailer_class is MemberMailer because it sends out emails to members of companies' do
    expect(described_class.instance.mailer_class).to eq MemberMailer
  end


  it '.company_recipients returns all current_members' do
    member1_c2_exp_jun6
    member2_c2_exp_jun1
    expect(described_class.instance.company_recipients(c2_2_members)).to match_array([member1_c2_exp_jun6, member2_c2_exp_jun1])
  end

  
  it '.success_str returns a string with member and company info' do
    expect(described_class.instance.success_str(c1_all_paid, member1_c1_exp_jun6))
        .to eq "to user id: #{member1_c1_exp_jun6.id} email: #{member1_c1_exp_jun6.email} company id: #{c1_all_paid.id} name: company1"
  end


  describe '.failure_str' do

    context 'company is nil' do
      it 'member is nil prints nil for both' do
        expect(described_class.instance.failure_str(nil, nil))
            .to eq "to user is nil company is nil"
      end

      it 'member is not nil prints nil for the company and member id and email' do
        expect(described_class.instance.failure_str(nil, member1_c1_exp_jun6))
            .to eq "to user id: #{member1_c1_exp_jun6.id} email: #{member1_c1_exp_jun6.email} company is nil"
      end
    end # context 'company is nil'

    context 'company is not nil' do
      it 'member is nil prints nil for member and company info' do
        expect(described_class.instance.failure_str(c1_all_paid, nil))
            .to eq "to user is nil company id: #{c1_all_paid.id} name: company1"
      end

      it 'member is not nil prints info for both company and member id and email' do
        expect(described_class.instance.failure_str(c1_all_paid, member1_c1_exp_jun6))
            .to eq "to user id: #{member1_c1_exp_jun6.id} email: #{member1_c1_exp_jun6.email} company id: #{c1_all_paid.id} name: company1"
      end
    end # context 'company is nil'

  end # describe '.failure_str'


end
