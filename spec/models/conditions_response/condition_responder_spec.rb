require 'rails_helper'


RSpec.describe ConditionResponder, type: :model do


  describe '.condition_response' do

    it 'raises NoMethodError (must be defined by subclasses)' do

      condition    = Condition.create(class_name: 'MembershipExpireAlert',
                                      timing:     'before',
                                      config:     { days: [60, 30, 14, 2] })
      logfile_name = 'log.log'
      log          = ActivityLogger.open(File.join(Dir.mktmpdir, logfile_name), 'ConditionResponder', 'respond')

      expect { described_class.condition_response(condition, log) }.to raise_exception NoMethodError
    end

  end


  it 'DEFAULT_TIMING is :on' do
    expect(ConditionResponder::DEFAULT_TIMING).to eq :on
  end

  describe '.get_timing' do

    it 'always returns a symbol' do
      expect(ConditionResponder.get_timing(create(:condition, timing: :blorf))).to eq(:blorf)
    end

    context 'condition is nil' do
      it 'returns the DEFAULT TIMING' do
        expect(ConditionResponder.get_timing(nil)).to eq ConditionResponder::DEFAULT_TIMING
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



  describe '.days_from_today(timing, some_date)' do

    let(:nov_30) { Date.new(2018, 11, 30) }
    let(:dec_1)  { Date.new(2018, 12,  1) }
    let(:dec_2)  { Date.new(2018, 12,  2) }

    around(:each) do |example|
      Timecop.freeze(dec_1)
      example.run
      Timecop.return
    end


    context 'timing is before' do

      let(:timing_before) { ConditionResponder::TIMING_BEFORE }

      it 'today is 1 day before the date  = -1' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_before)).to eq(-1)
      end

      it 'date is on today = 0' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_before)).to eq 0
      end

      it 'today is 1 day after the date = 1' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_before)).to eq 1
      end

    end

    context 'timing is after' do

      let(:timing_after) { ConditionResponder::TIMING_AFTER }

      it 'today is 1 day after the date = 1' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_after)).to eq(1)
      end

      it 'date is on today = 0' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_after)).to eq 0
      end

      it 'today is 1 day before the date = -1' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_after)).to eq(-1)
      end

    end

    context 'timing is on (always returns 0 days away; this means always check on today)' do

      let(:timing_on) { ConditionResponder::TIMING_ON }

      it 'date is 1 day before today = 0' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_on)).to eq 0
      end

      it 'date is on today = 0' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_on)).to eq 0
      end

      it 'date is 1 day after today = 0' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_on)).to eq 0
      end

    end

  end


  describe '.timing_is_before?(timing)' do

  end


  describe '.timing_is_after?(timing)' do

  end


  describe '.timing_is_on?(timing)' do

  end


  describe '.timing_is_every_day?(timing)' do
    let(:condition) { build(:condition, :every_day) }
    let(:timing) { ConditionResponder.get_timing(condition) }

    it 'returns true if timing == :every_day' do
      expect(ConditionResponder.timing_is_every_day?(timing)).to be true
    end

    it 'returns false otherwise' do
      condition.timing = ConditionResponder::DEFAULT_TIMING
      expect(ConditionResponder.timing_is_every_day?(timing)).to be false
    end

  end
  
end
