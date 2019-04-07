require 'rails_helper'
require 'email_spec/rspec'
require 'timecop'


LOG_DIR      = 'tmp'
LOG_FILENAME = 'testlog.txt'


RSpec.describe UserEmailAlert, type: :model do

  let(:all_users) do
    [ create(:user, first_name: 'u1', email: 'u1@example.com'),
      create(:user, first_name: 'u2'),
      create(:user, first_name: 'u3')
    ]
  end

  let(:u1) { all_users.first }


  it '.entities_to_check returns all users (User.all)' do
    expect(described_class.instance.entities_to_check).to match_array(all_users)
  end

  it '.mailer_class is MemberMailer' do
    expect(described_class.instance.mailer_class).to eq MemberMailer
  end

  it '.mailer_args is a user' do
    expect(described_class.instance.mailer_args(u1)).to eq [u1]
  end


  it '.success_str returns a string with the user id and email' do
    expect(described_class.instance.success_str(u1)).to eq "to id: #{u1.id} email: u1@example.com"
  end


  describe '.failure_str returns a string with the user id and email unless user is nil' do

    it 'user is not nil' do
      expect(described_class.instance.failure_str(u1)).to eq "to id: #{u1.id} email: u1@example.com"
    end

    it 'user is nil' do
      expect(described_class.instance.failure_str(nil)).to eq 'user is nil'
    end
  end


  it '.send_alert_this_day?(timing, config, user) raises NoMethodError (should be defined by subclasses)' do
    config = {}
    timing = 'blorf' # doesn't matter what this is
    expect { described_class.instance.send_alert_this_day?(timing, config, u1) }.to raise_exception NoMethodError
  end


  it '.mailer_method raises NoMethodError' do
    expect { described_class.instance.mailer_method }.to raise_exception NoMethodError
  end

end
