require 'rails_helper'

require File.join( 'shared_examples', 'condition_responder_timing_shared')


RSpec.describe ConditionResponder, type: :model do

  let(:mock_log) { instance_double("ActivityLogger") }

  describe '.condition_response' do

    it 'raises NoMethodError (must be defined by subclasses)' do

      condition    = Condition.create(class_name: 'MembershipExpireAlert',
                                      timing:     'before',
                                      config:     { days: [60, 30, 14, 2] })

      expect { described_class.condition_response(condition, mock_log) }.to raise_exception NoMethodError
    end

  end


  it 'default timing is on' do
    expect(described_class.default_timing).to eq described_class.timing_on
  end

  describe '.get_timing' do

    it 'always returns a symbol' do
      expect(ConditionResponder.get_timing(create(:condition, timing: :blorf))).to eq(:blorf)
    end

    context 'condition is nil' do
      it 'returns the default timing' do
        expect(ConditionResponder.get_timing(nil)).to eq described_class.default_timing
      end
    end

    context 'condition is not nil' do
      it 'returns the timing from the condition if condition is not nil' do
        expect(ConditionResponder.get_timing(create(:condition, timing: :flurb))).to eq(:flurb)
      end
    end

  end


  it 'DEFAULT_CONFIG is an empty Hash' do
    default_c = ConditionResponder::DEFAULT_CONFIG
    expect(default_c).to be_a Hash
    expect(default_c).to be_empty
  end

  describe '.get_config' do

    context 'condition is nil' do
      it 'returns the DEFAULT_CONFIG TIMING' do
        expect(ConditionResponder.get_config(nil)).to eq ConditionResponder::DEFAULT_CONFIG
      end
    end

    context 'condition is not nil' do
      it 'returns the timing from the condition if condition is not nil' do
        expect(ConditionResponder.get_config(create(:condition, config: {mertz: 732} ))).to eq({mertz: 732})
      end
    end

  end



  describe '.days_a_date_is_away_from(a_date, timing, some_date)' do

    let(:nov_30) { Date.new(2018, 11, 30) }
    let(:dec_1)  { Date.new(2018, 12,  1) }
    let(:dec_2)  { Date.new(2018, 12,  2) }

    around(:each) do |example|
      Timecop.freeze(dec_1)
      example.run
      Timecop.return
    end


    context 'timing is before' do

      let(:timing_before) { described_class.timing_before }

      it '1st is 1 day before 2nd date  = 1' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(nov_30, dec_1, timing_before)).to eq 1
      end

      it '1st = 2nd date  == 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, dec_1, timing_before)).to eq 0
      end

      it '1st date is 1 day after 2nd date  = -1' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_2, dec_1, timing_before)).to eq -1
      end

    end

    context 'timing is after' do

      let(:timing_after) { described_class.timing_after }

      it '1st is 1 day before 2nd date  = -1' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(nov_30, dec_1, timing_after)).to eq -1
      end

      it '1st = 2nd date  == 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, dec_1, timing_after)).to eq 0
      end

      it '1st date is 1 day after 2nd date  = 1' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_2, dec_1, timing_after)).to eq 1
      end

    end


    context 'timing is on always returns 0 days away. Always check on the 2nd date no matter how many days away' do

      let(:timing_on) { described_class.timing_on }

      it '2nd date is 1 day before the date = 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, nov_30, timing_on)).to eq 0
      end

      it '2nd date is == the date = 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, dec_1, timing_on)).to eq 0
      end

      it '2nd date is 1 day after the date = 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, dec_2, timing_on)).to eq 0
      end

    end

  end


  describe '.days_today_is_away_from(timing, some_date)' do

    let(:nov_30) { Date.new(2018, 11, 30) }
    let(:dec_1)  { Date.new(2018, 12,  1) }
    let(:dec_2)  { Date.new(2018, 12,  2) }

    around(:each) do |example|
      Timecop.freeze(dec_1)
      example.run
      Timecop.return
    end


    context 'timing is before' do

      let(:timing_before) { described_class.timing_before }

      it 'today is 1 day before the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_before)' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_before)).to eq ConditionResponder.days_1st_date_is_from_2nd(dec_1, nov_30, timing_before)
      end

      it 'today = the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_before)' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_before)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_before)
      end

      it 'today is 1 day after the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_before)' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_before)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_before)
      end

    end

    context 'timing is after' do

      let(:timing_after) { described_class.timing_after }

      it 'today is 1 day after the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_after)' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_after)).to eq  ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_after)
      end

      it 'date is on today = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_after)' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_after)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_after)
      end

      it 'today is 1 day before the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_after)' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_after)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_after)
      end

    end


    context 'timing is on always returns 0 days away. Always check on today' do

      let(:timing_on) { described_class.timing_on }

      it 'date is 1 day before today = ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_on)' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_on)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_on)
      end

      it 'date is on today = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_on)' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_on)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_on)
      end

      it 'date is 1 day after today = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_on)' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_on)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_on)
      end

    end

  end

  context 'timing predicate methods' do

    let(:condition) { build(:condition) }
    let(:timing) { ConditionResponder.get_timing(condition) }


    describe '.timing_is_before?(timing)' do
      it_behaves_like 'timing method is true if timing matches, else false', :timing_is_before?, described_class.timing_before
    end

    describe '.timing_is_after?(timing)' do
      it_behaves_like 'timing method is true if timing matches, else false', :timing_is_after?, described_class.timing_after
    end

    describe '.timing_is_on?(timing)' do
      it_behaves_like 'timing method is true if timing matches, else false', :timing_is_on?, described_class.timing_on
    end

    describe '.timing_is_every_day?(timing)' do
      it_behaves_like 'timing method is true if timing matches, else false', :timing_is_every_day?, described_class.timing_every_day
    end

    describe '.timing_is_day_of_month?' do
      it_behaves_like 'timing method is true if timing matches, else false', :timing_is_day_of_month?, described_class.timing_day_of_month
    end
  end


  describe '.timing_matches_today?' do

    let(:condition) { build(:condition) }
    let(:timing) { ConditionResponder.get_timing(condition) }

    it 'true if timing is every day' do
      config = {}
      expect(ConditionResponder.timing_matches_today?(described_class.timing_every_day, config)).to be_truthy
    end

    it 'true if today is timing day of month? and this is that day of the month' do
      condition.timing = described_class.timing_day_of_month
      config = {days: [Date.current.day]}
      expect(ConditionResponder.timing_matches_today?(described_class.timing_day_of_month, config)).to be_truthy
    end

    it 'false otherwise' do
      condition.timing = described_class.default_timing
      expect(ConditionResponder.timing_matches_today?(timing, config)).to be_falsey
    end
  end


  describe '.today_is_timing_day_of_month?' do

    let(:condition) { build(:condition, timing: described_class.timing_day_of_month) }
    let(:timing) { described_class.get_timing(condition) }

    it "true if the timing is 'day of month' and config[:days] includes today's day of the month" do
      config = {days: [Date.current.day]}
      expect(ConditionResponder.today_is_timing_day_of_month?(timing, config)).to be_truthy
    end

    it "false if :days is not in config" do
      config = {}
      expect(ConditionResponder.today_is_timing_day_of_month?(timing, config)).to be_falsey
    end

    it "false if config[:days] does not include today's date" do
      config = {days: [Date.current.day - 1,  Date.current.day + 1]}
      expect(ConditionResponder.today_is_timing_day_of_month?(timing, config)).to be_falsey
    end

  end


  describe '.confirm_correct_timing' do

    let(:condition) { build(:condition, :every_day) }
    let(:timing) { ConditionResponder.get_timing(condition) }

    it 'does not raise exception if received timing == expected' do
      expect(described_class).to receive(:validate_timing).with(:every_day, [:every_day], mock_log)

      expect { ConditionResponder.confirm_correct_timing(:every_day, :every_day, mock_log) }
        .not_to raise_error
    end

    it 'raises exception if received timing != expected' do
      expect(described_class).to receive(:validate_timing).with(:not_a_valid_timing, [:every_day], mock_log)
      ConditionResponder.confirm_correct_timing(:not_a_valid_timing, :every_day, mock_log)
    end

  end


  describe '.validate_timing' do

    def invalid_timing_error_msg(invalid_timing, valid_list)
      "Received timing :#{invalid_timing} which is not in list of expected timings: #{valid_list}"
    end


    it 'does not raise exception if timing IS in list of expected timings' do
      expect { described_class.validate_timing(:valid_timing, [:valid_timing, :another_valid_timing], mock_log) }
          .not_to raise_error
    end

    it 'raises TimingNotValidConditionResponderError and writes to log if timing is not in list of expected timings' do
      err_str = "Received timing :not_a_valid_timing which is not in list of expected timings: [:valid_timing, :another_valid_timing]"
      expect(mock_log).to receive(:record).with('error', err_str)
      expect { described_class.validate_timing(:not_a_valid_timing, [:valid_timing, :another_valid_timing], mock_log) }
          .to raise_error TimingNotValidError, err_str
    end

    it 'raises ExpectedTimingsCannotBeEmptyError and writes to log if list of expected timings is empty' do
      err_str = "List of expected timings cannot be empty"
      expect(mock_log).to receive(:record).with('error', err_str)
      expect { described_class.validate_timing(:not_a_valid_timing, [], mock_log) }
          .to raise_error ExpectedTimingsCannotBeEmptyError, err_str
    end


    describe 'valid timings can be a single Timing (it will convert to an Array)' do

      it 'does not raise exception if timing is the expected single Timing' do
        expect { described_class.validate_timing(:valid_timing, :valid_timing, mock_log) }
            .not_to raise_error
      end

      it 'raises TimingNotValidConditionResponderError and writes to log if timing is NOT the expected single Timing' do
        err_str = invalid_timing_error_msg(:not_a_valid_timing, [:valid_timing])
        expect(mock_log).to receive(:record).with('error', err_str)
        expect { described_class.validate_timing(:not_a_valid_timing, :valid_timing, mock_log) }
            .to raise_error TimingNotValidError, err_str
      end

    end
  end

end
