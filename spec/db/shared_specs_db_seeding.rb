require 'rails_helper'
require_relative File.join(Rails.root, 'db', 'seeders', 'app_configuration_seeder')

ENV_ADMIN_EMAIL_KEY = 'SHF_ADMIN_EMAIL' unless defined?(ENV_ADMIN_EMAIL_KEY)
ENV_ADMIN_PASSWORD_KEY = 'SHF_ADMIN_PWD' unless defined?(ENV_ADMIN_PASSWORD_KEY)
ENV_NUM_SEEDED_USERS_KEY = 'SHF_SEED_USERS' unless defined?(ENV_NUM_SEEDED_USERS_KEY)
ENV_SEED_FAKE_CSV_FNAME_KEY = 'SHF_SEED_FAKE_ADDR_CSV_FILE' unless defined?(ENV_SEED_FAKE_CSV_FNAME_KEY)

#========================================================================================


RSpec.shared_examples 'admin, business categories, kommuns, and regions are seeded' do |rails_env, admin_email, admin_pwd|

  describe 'happy path - all is correct' do

    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("#{rails_env}"))

        allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
        allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
        allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY    => admin_email,
                                             ENV_ADMIN_PASSWORD_KEY => admin_pwd}) )

        allow(Seeders::AppConfigurationSeeder).to receive(:seed).and_return(true)

        allow(Seeders::MasterChecklistTypesSeeder).to receive(:seed).and_return([])
        allow(Seeders::MasterChecklistsSeeder).to receive(:seed).and_return([])
        allow(Seeders::UserChecklistsSeeder).to receive(:seed).and_return([])
        allow(SeedHelper::UsersFactory ).to receive(:seed_predefined_users).and_return(true)

        # stub these methods do AppConfiguration isn't called
        allow(Membership).to receive(:term_length).and_return(10)  # so AppConfiguration is not called
        allow(MembershipsManager).to receive(:grace_period).and_return(90)
        allow(MembershipsManager).to receive(:days_can_renew_early).and_return(10)
        allow(MembershipsManager).to receive(:is_expiring_soon_amount).and_return(30)

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

        allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
        allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
        allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

        allow(Seeders::MasterChecklistTypesSeeder).to receive(:seed).and_return([])
        allow(Seeders::MasterChecklistsSeeder).to receive(:seed).and_return([])

        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => admin_email,
                                             ENV_ADMIN_PASSWORD_KEY => admin_pwd}) )

        allow(Seeders::AppConfigurationSeeder).to receive(:seed).and_return(true)

        allow(Membership).to receive(:term_length).and_return(10)  # so AppConfiguration is not called
      end
    end

    it 'admin email not found (an ERROR will be RESCUED)' do
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

      admin_email_value = ENV.delete(ENV_ADMIN_EMAIL_KEY)
      puts EXPECT_ERR_MSG
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
      ENV[ENV_ADMIN_EMAIL_KEY] = admin_email_value
    end

    it 'admin email is an empty string (an ERROR will be RESCUED)' do
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

      stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => ''}) )
      puts EXPECT_ERR_MSG
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
    end

    it 'admin password not found (an ERROR will be RESCUED)' do
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

      admin_password_value = ENV.delete(ENV_ADMIN_PASSWORD_KEY)
      puts EXPECT_ERR_MSG
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
      ENV[ENV_ADMIN_PASSWORD_KEY] = admin_password_value
    end

    it 'admin password is an empty string (an ERROR will be RESCUED)' do
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

      stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_PASSWORD_KEY => ''}) )
      puts EXPECT_ERR_MSG
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
    end
  end

end



#========================================================================================


RSpec.shared_examples 'it calls geocode min max times with csv file' do |num_users, admin_email, admin_pwd, geocode_min, geocode_max, csv_filename|

  it "seed #{num_users}, calls Geocode.search at least #{geocode_min} and at most #{geocode_max} times" do
    RSpec::Mocks.with_temporary_scope do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))

      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
      allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
      allow_any_instance_of(SeedHelper::AddressFactory).to receive(:tell).and_return(false)

      allow(Seeders::UserChecklistsSeeder).to receive(:seed).and_return([])
      allow(Membership).to receive(:term_length).and_return(10)  # so AppConfiguration is not called

      stub_const('ENV', ENV.to_hash.merge({ ENV_NUM_SEEDED_USERS_KEY    => num_users,
                                            ENV_SEED_FAKE_CSV_FNAME_KEY => csv_filename,
                                            ENV_ADMIN_EMAIL_KEY         => admin_email,
                                            ENV_ADMIN_PASSWORD_KEY      => admin_pwd }))

      if geocode_min == 0
        expect(Geocoder).to receive(:search).never
      else
        expect(Geocoder).to receive(:search).at_least(geocode_min).times
      end

      expect(Geocoder).to receive(:search).at_most(geocode_max).times if geocode_max > 0

      allow(Seeders::AppConfigurationSeeder).to receive(:seed).and_return(true)

      SHFProject::Application.load_seed

      expect(User.count).to eq num_users
      expect(Address.count).to eq Company.count

    end
    # TODO: Simple transaction DB cleanup is not enough here, could be worth
    #       finding out why.
  end
end
