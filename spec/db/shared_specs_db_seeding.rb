require 'rails_helper'
require_relative File.join(Rails.root, 'db', 'seeders', 'app_configuration_seeder')
require_relative File.join(__dir__, '..', 'shared_context', 'mock_app_configuration')

ENV_ADMIN_EMAIL_KEY = 'SHF_ADMIN_EMAIL' unless defined?(ENV_ADMIN_EMAIL_KEY)
ENV_ADMIN_PASSWORD_KEY = 'SHF_ADMIN_PWD' unless defined?(ENV_ADMIN_PASSWORD_KEY)
ENV_NUM_SEEDED_USERS_KEY = 'SHF_SEED_USERS' unless defined?(ENV_NUM_SEEDED_USERS_KEY)
ENV_SEED_FAKE_CSV_FNAME_KEY = 'SHF_SEED_FAKE_ADDR_CSV_FILE' unless defined?(ENV_SEED_FAKE_CSV_FNAME_KEY)

TERM_LENGTH_DAYS = 365
GRACE_PERIOD_DAYS = 90
CAN_RENEW_EARLY_DAYS = 10
EXPIRING_SOON_DAYS = 30


def stub_rails_env(env = 'development')
  allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(env))
end


def no_logging
  allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
  allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
  allow_any_instance_of(SeedHelpers::AddressFactory).to receive(:tell).and_return(false)
end


def stub_admin_email_and_password(admin_email = '', admin_pwd = '', other_info = {})
  stub_const('ENV', ENV.to_hash.merge({ ENV_ADMIN_EMAIL_KEY         => admin_email,
                                        ENV_ADMIN_PASSWORD_KEY      => admin_pwd },
                                      other_info))
end


def stub_app_config_seeder
  allow(Seeders::AppConfigurationSeeder).to receive(:seed).and_return(true)
end


def mock_the_app_configuration
  allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)
end


def stub_membership_terms_and_days
  # stub these so AppConfiguration is not called:
  allow(SeedHelpers::UsersFactory).to receive(:term_length_to_days).and_return(TERM_LENGTH_DAYS)
  allow(SeedHelpers::UsersFactory).to receive(:grace_period_to_days).and_return(GRACE_PERIOD_DAYS)
  allow(MembershipsManager).to receive(:days_can_renew_early).and_return(CAN_RENEW_EARLY_DAYS)
  allow(MembershipsManager).to receive(:is_expiring_soon_amount).and_return(EXPIRING_SOON_DAYS)
end


def stub_checklist_seeding
  allow(Seeders::MasterChecklistTypesSeeder).to receive(:seed).and_return([])
  allow(Seeders::MasterChecklistsSeeder).to receive(:seed).and_return([])
  allow(Seeders::UserChecklistsSeeder).to receive(:seed).and_return([])
end


def dont_seed_predefined_users_members
  # Don't seed the predefined ones.  Only seed the number we give it
  allow_any_instance_of(SeedHelpers::UsersFactory ).to receive(:seed_predefined_users).and_return(true)
end


def dont_make_completed_membership_guidelines
  allow_any_instance_of(SeedHelpers::UsersFactory).to receive(:make_completed_membership_guidelines_for).and_return(true)
end


def dont_upload_files_for_membership_app
  allow_any_instance_of(SeedHelpers::UsersFactory).to receive(:upload_membership_application_file).and_return(true)
end

#========================================================================================

RSpec.shared_examples 'admin, business categories, kommuns, and regions are seeded' do |rails_env, admin_email, admin_pwd|

  describe 'happy path - all is correct' do

    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("#{rails_env}"))

        # TODO: Simple transaction DB cleanup is not enough here. Why?
        DatabaseCleaner.clean_with :truncation
        no_logging
        stub_admin_email_and_password(admin_email, admin_pwd)
        mock_the_app_configuration
        stub_app_config_seeder
        stub_checklist_seeding
        dont_seed_predefined_users_members
        stub_membership_terms_and_days
        dont_make_completed_membership_guidelines
        dont_upload_files_for_membership_app

        SHFProject::Application.load_tasks
        SHFProject::Application.load_seed
      end
    end

    after(:all) do
      # TODO: Simple transaction DB cleanup is not enough here, could be worth
      #       finding out why.
      DatabaseCleaner.clean_with :truncation
    end


    let(:admin_in_db) { User.find_by_email(admin_email) }

    it "#{admin_email} is in the db" do
      expect(admin_in_db).not_to be_nil
    end

    it 'admin is in the db' do
      expect(admin_in_db.admin).to be_truthy
    end

    it "admin email is = #{admin_email}" do
      expect(admin_in_db.email).to eq(admin_email)
    end

    it "admin password is in the db" do
      expect(admin_in_db.valid_password?(admin_pwd)).to be_truthy
    end

    it 'business categories are in the db' do
      expect(BusinessCategory.all.size).to eq(11)
    end

    it 'regions are in the db' do
      expect(Region.all.size).to eq(23)
    end

    it 'kommuns are in the db' do
      expect(Kommun.all.size).to eq(290)
    end

  end


  describe 'sad path: errors are raised' do

    EXPECT_ERR_MSG = "\n-----\nexpect ERROR RESCUED! to happen:" unless defined?(EXPECT_ERR_MSG)

    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("#{rails_env}"))

        allow(Seeders::MasterChecklistTypesSeeder).to receive(:seed).and_return([])
        allow(Seeders::MasterChecklistsSeeder).to receive(:seed).and_return([])

        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => admin_email,
                                             ENV_ADMIN_PASSWORD_KEY => admin_pwd}) )
      end
    end

    it 'admin email not found (an ERROR will be RESCUED)' do
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelpers::AddressFactory).to receive(:tell).and_return(false)

      admin_email_value = ENV.delete(ENV_ADMIN_EMAIL_KEY)
      puts EXPECT_ERR_MSG
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
      ENV[ENV_ADMIN_EMAIL_KEY] = admin_email_value
    end

    it 'admin email is an empty string (an ERROR will be RESCUED)' do
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelpers::AddressFactory).to receive(:tell).and_return(false)

      stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => ''}) )
      puts EXPECT_ERR_MSG
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
    end

    it 'admin password not found (an ERROR will be RESCUED)' do
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelpers::AddressFactory).to receive(:tell).and_return(false)

      admin_password_value = ENV.delete(ENV_ADMIN_PASSWORD_KEY)
      puts EXPECT_ERR_MSG
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
      ENV[ENV_ADMIN_PASSWORD_KEY] = admin_password_value
    end

    it 'admin password is an empty string (an ERROR will be RESCUED)' do
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelpers::AddressFactory).to receive(:tell).and_return(false)

      stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_PASSWORD_KEY => ''}) )
      puts EXPECT_ERR_MSG
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
    end
  end

end
