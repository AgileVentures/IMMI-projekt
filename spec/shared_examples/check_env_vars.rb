# RSpec shared example to check that all needed ENV variables are defined
#
# Ex:
#   require 'check_env_vars'
#
#   RSpec.describe 'whatever' do
#
#      it_behaves_like 'expected ENV variables exist', %w( SHF_EXPECTED_VAR_1, SHF_EXPECTED_VAR_2)
#
#   end
#
#
RSpec.shared_examples "expected ENV variables exist" do | list_of_env_names |

  env_file_info = "Define this in your .env.test file.  See .env.test.example for more info."

  env_hash = ENV.to_hash

  list_of_env_names.each do |env_var|

    it "#{env_var}" do
      expect(env_hash.fetch(env_var, nil)).not_to be_nil, "You must have the ENV variable '#{env_var}' set.  #{env_file_info}"
    end
  end
end
