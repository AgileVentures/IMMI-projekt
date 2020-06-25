require 'rails_helper'

RSpec.describe OneTimeTasker::TaskAttempt, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:one_time_tasker_task_attempt)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :task_name }
    it { is_expected.to have_db_column :task_source }
    it { is_expected.to have_db_column :was_successful }
    it { is_expected.to have_db_column :attempted_on }
    it { is_expected.to have_db_column :notes }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :task_name }
    it { is_expected.to validate_presence_of :attempted_on }

    describe 'was_successful must be the right type and we must have an attempted_on time' do
      before(:each) do
        subject.task_name = 'blorf'
      end

      describe 'was_successful must be a boolean' do
        before(:each) do
          subject.attempted_on = Time.zone.now
        end

        it 'calls the :was_successful_is_boolean method to validate' do
          expect(subject).to receive(:was_successful_is_boolean).and_call_original
          subject.was_successful = true
          expect(subject.valid?).to be_truthy
        end

        # Rails will allow was_successful to be a String if you use the common validations per the Guides example
        describe 'not valid if it is a String or Integer' do
          invalid_values = [0, 1, 'blorf']
          invalid_values.each do | invalid_value |
            it "#{invalid_value} is valid" do
              subject.was_successful = invalid_value
              expect(subject.valid?).to be_truthy
            end
          end
        end

        describe 'valid only if it is a TrueClass or FalseClass' do
          valid_values = [true, false]
          valid_values.each do | valid_value |
            it "#{valid_value} is valid" do
              subject.was_successful = valid_value
              expect(subject.valid?).to be_truthy
            end
          end
        end
      end

      it 'attempted_on is a time (is not nil)' do
        subject.was_successful = true
        subject.attempted_on = Time.zone.now
        expect(subject.valid?).to be_truthy
      end

      it 'attempted_on is nil' do
        subject.was_successful = true
        subject.attempted_on = nil
        expect(subject.valid?).to be_falsey
      end
    end
  end

  describe 'scopes' do
    before(:each) do
      create(:one_time_tasker_task_attempt, :successful_task)
      create(:one_time_tasker_task_attempt, :successful_task)
      create(:one_time_tasker_task_attempt, :successful_task)
      create(:one_time_tasker_task_attempt, :unsuccessful_task)
      create(:one_time_tasker_task_attempt, :unsuccessful_task)
    end

    it 'successful is all tasks that have been run successfully' do
      expect(described_class.successful.count).to eq 3
    end

    it 'unsuccessful is all tasks that have not been run successfully' do
      expect(described_class.unsuccessful.count).to eq 2
    end

    it 'successful tasks + unsuccessful tasks = total number of tasks (all tasks must be either successful or unsuccessful)' do
      expect(described_class.successful.count + described_class.unsuccessful.count).to eq described_class.count
    end
  end
end
