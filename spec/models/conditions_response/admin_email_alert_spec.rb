require 'rails_helper'
require 'email_spec/rspec'
require 'timecop'


RSpec.describe AdminEmailAlert, type: :model do

  let(:mock_log) { instance_double("ActivityLogger") }

  # define subject for this Singleton class
  let(:subject) { described_class.instance }


  let(:all_users) do
    [ create(:user, first_name: 'u1', email: 'u1@example.com'),
      create(:user, first_name: 'u2'),
      create(:user, first_name: 'u3')
    ]
  end

  let(:u1) { all_users.first }

  let(:admin1) { create(:admin, first_name: 'admin1', email: 'admin1@example.com') }
  let(:admin2) { create(:admin, first_name: 'admin2') }
  let(:admin3) { create(:admin, first_name: 'admin3') }

  let(:all_admins) { [ admin1, admin2, admin3 ] }

  let(:blank_config) { {  } }
  let(:every_day_timing) { AdminEmailAlert::TIMING_EVERY_DAY }



  it '.mailer_class is AdminMailer' do
    expect(subject.mailer_class).to eq AdminMailer
  end


  it '.mailer_args is an admin returns the admin _and_ entites_to_check ' do

    allow(subject).to receive(:entities_list).and_return(all_users)

    expect(subject.mailer_args(admin1)).to match_array [admin1, all_users]
  end


  describe 'process_entities' do

    it 'loops thru entities_to_check and calls take_action for each one' do

      # don't call send_mail
      allow(subject).to receive(:send_alert_this_day?).and_return(true)

      # stub this method
      allow(subject).to receive(:add_entity_to_list?).with(anything).and_return(true)

      # expectation
      expect(subject).to receive(:take_action).exactly(all_users.size).times

      subject.process_entities( all_users, mock_log)
    end

    it 'does not send email if the entities list is empty' do
      # don't call send_mail
      allow(subject).to receive(:send_alert_this_day?).and_return(false)

      # expectation
      expect(subject).not_to receive(:take_action)

      subject.process_entities([], mock_log)
    end

    describe 'sends email with the entities_list iff entities list is not empty AND send_alert_this_day? is true' do

      it 'send_alert_this_day? is true' do
        # stub this method
        allow(subject).to receive(:add_entity_to_list?).and_return(true)

        # setup
        allow(subject).to receive(:send_alert_this_day?).and_return(true)

        # expectation
        expect(subject).to receive(:send_email).exactly(all_admins.size).times

        subject.process_entities(all_users, mock_log)
      end

      it 'send_alert_this_day? is false' do
        # stub this method
        allow(subject).to receive(:add_entity_to_list?).and_return(true)

        # setup
        allow(subject).to receive(:send_alert_this_day?).and_return(false)

        # expectation
        expect(subject).not_to receive(:send_email)

        subject.process_entities(all_users, mock_log)

      end

    end

  end


  describe 'entities_to_check is all users except admins' do

    it 'includes all users that are not admins' do
      expect(subject.entities_to_check).to match_array(all_users)
    end

    it 'does not include admins' do
      expect(subject.entities_to_check).not_to include(admin1)
      expect(subject.entities_to_check).not_to include(admin2)
      expect(subject.entities_to_check).not_to include(admin3)
    end

  end


  describe 'take_action adds a user to entities_list if add_entity_to_list? is true' do

    it 'add_entity_to_list? is true' do

      allow(subject).to receive(:add_entity_to_list?).and_return(true)

      expect(subject).to receive(:entities_list).and_call_original

      subject.take_action(u1, mock_log)

    end


    it 'add_entity_to_list? is false' do
      allow(subject).to receive(:add_entity_to_list?).and_return(false)

      expect(subject).not_to receive(:entities_list)

      subject.take_action(u1, mock_log)
    end
  end


  it 'add_entity_to_list? raises NoMethodError (subclass must define)' do
    expect { subject.add_entity_to_list?(u1) }.to raise_exception NoMethodError
  end


  it '.success_str returns a string with the admin id and email' do
    expect(subject.success_str(admin1)).to eq "to id: #{admin1.id} email: admin1@example.com"
  end


  describe '.failure_str returns a string with the admin id and email unless admin is nil' do

    it 'admin is not nil' do
      expect(subject.failure_str(admin1)).to eq "to id: #{admin1.id} email: admin1@example.com"
    end

    it 'admin is nil' do
      expect(subject.failure_str(nil)).to eq 'admin is nil'
    end
  end


  describe '.send_alert_this_day?(timing, config, user) true if timing_matches_today?' do

    it 'timing_matches_today? is true' do
      config = {}
      timing = ConditionResponder::TIMING_EVERY_DAY
      expect(subject.send_alert_this_day?(timing, config)).to be_truthy
    end

    it 'timing_matches_today? is false' do
      config = {}
      timing = 'blorf' # doesn't matter what this is
      expect(subject.send_alert_this_day?(timing, config)).to be_falsey
    end

  end


  it '.mailer_method raises NoMethodError' do
    expect { subject.mailer_method }.to raise_exception NoMethodError
  end

end
