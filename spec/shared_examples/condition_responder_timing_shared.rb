# Shared specification examples for ConditionResponder timing


# @return [Array] - all valid timings excluding a_timing
def timings_without(a_timing)
  described_class.all_timings - [a_timing]
end


RSpec.shared_examples 'timing method is true if timing matches, else false' do |timing_method, a_timing |

  describe "#{timing_method}" do
    it "true if timing == #{a_timing}" do
      expect(ConditionResponder.send(timing_method, a_timing)).to be_truthy
    end

    describe 'false otherwise' do

      timings_without(a_timing).each do |other_timing|
        it "#{other_timing}" do
          expect(ConditionResponder.send(timing_method, other_timing)).to be_falsey
        end
      end
    end
  end

end
