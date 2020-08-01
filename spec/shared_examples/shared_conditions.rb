# Shared specification examples for Conditions


RSpec.shared_examples 'it validates timings in .condition_response' do | valid_timing_list |

  let(:mock_log) { instance_double("ActivityLogger") }


  expected_list = valid_timing_list.is_a?(Enumerable) ? valid_timing_list : [valid_timing_list]

  unexpected_timings = ConditionResponder.all_timings - expected_list

  unexpected_timings.each do |unexpected_timing|

    it "#{unexpected_timing} is not one of the expected timings: #{expected_list}" do

      condition.timing = unexpected_timing
      err_str          = "Received timing :#{unexpected_timing} which is not in list of expected timings: #{expected_list}"

      expect(described_class).to receive(:validate_timing).and_call_original

      expect(mock_log).to receive(:record).with("error", err_str)

      expect { described_class.condition_response(tested_condition, mock_log) }
          .to raise_exception TimingNotValidError, err_str
    end

  end
end
