require 'rails_helper'
require 'create_membership_seq_if_needed'

require File.join(Rails.root, 'db/require_all_seeders_and_helpers.rb')
require File.join(__dir__, 'shared_specs_db_seeding')
require_relative '../shared_context/mock_app_configuration.rb'

# TODO lots of redundant stubbing and mocking (e.g. in before(:all), etc). I'm unclear exactly when
#    they are or are not applied. This is working, but needs to be cleaned up.

# NOTE: We must stub AppConfigurationSeeder.seed so that Paperclip does not try to spawn processes.
# Some of those spawned processes will Fail (or even SEGFAULT!).
# This seems to do with running them under RSpec and the .load_seed method.
# The AppConfigurationSeeder.seed method works fine in real life.


ENV_ADMIN_EMAIL_KEY         = 'SHF_ADMIN_EMAIL' unless defined?(ENV_ADMIN_EMAIL_KEY)
ENV_ADMIN_PASSWORD_KEY      = 'SHF_ADMIN_PWD' unless defined?(ENV_ADMIN_PASSWORD_KEY)
ENV_NUM_SEEDED_USERS_KEY    = 'SHF_SEED_USERS' unless defined?(ENV_NUM_SEEDED_USERS_KEY)
ENV_SEED_FAKE_CSV_FNAME_KEY = 'SHF_SEED_FAKE_ADDR_CSV_FILE' unless defined?(ENV_SEED_FAKE_CSV_FNAME_KEY)

SEED_6_USERS = 6


RSpec.describe 'Dev DB is seeded with users, members, apps, and companies' do

  admin_email = 'the-shfadmin@shf.org'
  admin_pwd   = 'insecure-password'

  before(:all) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
    create_user_membership_num_seq_if_needed

    RSpec::Mocks.with_temporary_scope do
      stub_rails_env('development') # Stub this so seeding will happen
      no_logging
      mock_the_app_configuration
      stub_app_config_seeder
      stub_checklist_seeding
      stub_membership_terms_and_days
      stub_admin_email_and_password(admin_email, admin_pwd)
      allow_any_instance_of(SeedHelpers::UsersFactory).to receive(:seed_users_and_members).and_return(true)
      SHFProject::Application.load_tasks
    end
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  before(:each) do
    dont_seed_predefined_users_members
  end


  describe 'seeding basic info: users, companies, etc.' do

    # seed with a minimum of 4 users to cover: admin, no application, single
    # application, double application
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        stub_rails_env('development') # Stub this so seeding will happen
        no_logging
        stub_admin_email_and_password(admin_email, admin_pwd,
                                      { ENV_NUM_SEEDED_USERS_KEY => SEED_6_USERS })
        mock_the_app_configuration
        stub_app_config_seeder
        stub_membership_terms_and_days
        allow(Seeders::UserChecklistsSeeder).to receive(:seed).and_return([])

        dont_seed_predefined_users_members
        dont_make_completed_membership_guidelines
        dont_upload_files_for_membership_app
        SHFProject::Application.load_seed
      end
    end

    describe 'initial state before extra info is added' do
      it_behaves_like 'admin, business categories, kommuns, and regions are seeded', 'development', admin_email, admin_pwd
    end

    it 'users are in the db' do
      expect(User.count).to eq(SEED_6_USERS)
    end

    it 'addresses are in the db' do
      expect(Address.count).to eq(ShfApplication.count)
    end

    it 'companies are in the db' do
      expect(Company.count).to eq(ShfApplication.count)
    end

    it 'memberships applications are in the db' do
      expect(ShfApplication.count).to eq(SEED_6_USERS - 2)
    end

  end


  describe 'addresses' do

    NUM_USERS = 7 unless defined?(NUM_USERS)

    SEED_DB_DIR = File.join(Rails.root, 'db') unless defined?(SEED_DB_DIR)
    EMPTY_CSV_FILENAME = 'fake-addresses-empty.csv' unless defined?(EMPTY_CSV_FILENAME)

    # CSV file content for 10 fake addresses with geocoding
    FAKE_ADDRESSES              = "street_address,post_code,city,country,region_name,kommun_name,latitude,longitude,visibility,mail\n" +
        '"Percy Ahnhems Väg 5b","91279","Tidaholm","Sverige","Sverige","Söderköping",58.4823802,16.3216224,street_address,false' + "\n" +
        '"Vultejusvägen 3b","90 605","Katrineholm","Sverige","Örebro","Hofors",60.4854704,16.4535389582223,street_address,false' + "\n" +
        '"Tabergsvägen 609","61481","Mönsterås","Sverige","Västmanland","Vingåker",59.0433723,15.8715565,street_address,false' + "\n" +
        '"Förmansvägen 489","87 667","Karlstad","Sverige","Norrbotten","Trelleborg",55.37592,13.1461522,street_address,false' + "\n" +
        '"Per Albins Väg 4b","81403","Motala","Sverige","Östergötland","Sotenäs",58.37628605,11.1011196042114,street_address,false' + "\n" +
        '"Klara Östra Kyrkogata 623","68 349","Karlskrona","Sverige","Online","Sölvesborg",56.0506535,14.5871906,street_address,false' + "\n" +
        '"Engelbrektsgatan 80","06875","Strömstad","Sverige","Online","Nässjö",57.6530377,14.6981554,street_address,false' + "\n" +
        '"Skaraborgsgatan 9b","08247","Laholm","Sverige","Gävleborg","Ockelbo",60.9197006,16.5426709711809,street_address,false' + "\n" +
        '"Surtsögatan 9a","64 898","Solna","Sverige","Sverige","Norsjö",64.93630935,19.4762167086367,street_address,false' + "\n" +
        '"Huvudfabriksgatan 4a","56 407","Nyköping","Sverige","Värmland","Flen",59.0567823,16.5893,street_address,false' + "\n"  unless defined?(FAKE_ADDRESSES)

    FAKE_ADDRESSES_CSV_FILENAME = "fake-addresses-10-#{Time.now.to_i}.csv" unless defined?(FAKE_ADDRESSES_CSV_FILENAME)



    shared_examples 'it creates new addresses min max times with csv file' do |num_users, a_email, a_pwd, min_times, max_times, csv_filename|

      it "seed #{num_users}, calls Geocode.search at least #{min_times} and at most #{max_times} times" do

        RSpec::Mocks.with_temporary_scope do
          DatabaseCleaner.strategy = :transaction
          DatabaseCleaner.start
          no_logging

          # Stub this so seeding will happen
          stub_rails_env('development')
          other_env_info = { ENV_NUM_SEEDED_USERS_KEY    => num_users,
                             ENV_SEED_FAKE_CSV_FNAME_KEY => csv_filename }
          stub_admin_email_and_password(a_email, a_pwd, other_env_info)

          mock_the_app_configuration
          stub_app_config_seeder
          stub_checklist_seeding
          dont_seed_predefined_users_members
          stub_membership_terms_and_days
          dont_make_completed_membership_guidelines
          dont_upload_files_for_membership_app

          if min_times == 0
            expect_any_instance_of(SeedHelpers::AddressFactory).to receive(:create_a_new_address).never
          else
            expect_any_instance_of(SeedHelpers::AddressFactory).to receive(:create_a_new_address)
                                                                     .at_least(min_times).times
          end

          expect_any_instance_of(SeedHelpers::AddressFactory).to receive(:create_a_new_address)
                                                                   .at_most(max_times).times if max_times > 0

          SHFProject::Application.load_tasks
          SHFProject::Application.load_seed

          expect(User.count).to eq num_users
        end
      end
    end

    # ---------------------------------------------------------------------------------------------


    before(:all) do
      create_empty_file(SEED_DB_DIR, EMPTY_CSV_FILENAME)
      create_csv_file(SEED_DB_DIR, FAKE_ADDRESSES_CSV_FILENAME, FAKE_ADDRESSES)
    end

    before(:each) do
      create_user_membership_num_seq_if_needed
      DatabaseCleaner.clean_with :transaction
    end

    after(:all) do
      # remove the CSV files created
      remove_file(SEED_DB_DIR, EMPTY_CSV_FILENAME)
      remove_file(SEED_DB_DIR, FAKE_ADDRESSES_CSV_FILENAME)
    end



    # We can't know exactly how many addresses are created because some randomness is used
    context 'all addresses are created and geocoded' do
      it_behaves_like 'it creates new addresses min max times with csv file', NUM_USERS, admin_email, admin_pwd, 5, 10, EMPTY_CSV_FILENAME
    end

    context 'get all addresses from a CSV file (no geocoding)' do
      it_behaves_like 'it creates new addresses min max times with csv file', NUM_USERS, admin_email, admin_pwd, 0, 0, FAKE_ADDRESSES_CSV_FILENAME
    end

    context 'not enough addresses are in the CSV file; create the remaining ones needed' do
      it_behaves_like 'it creates new addresses min max times with csv file', 16, admin_email, admin_pwd, 3, 5, FAKE_ADDRESSES_CSV_FILENAME
    end


    #----------------------------------------------------------------------------

    # Create an empty file in the given directory if it doesn't already exist
    #
    # @param fullpath [String] - the full path where the file should be created
    # @param filename [String] - the filename to create
    # @return [String] - the absolute pathname of the file
    def create_empty_file(fullpath, filename)
      fullname = File.join(fullpath, filename)
      File.new(fullname, 'w') unless File.exist?(fullname)
      File.absolute_path(fullname)
    end


    # Create a file with the given content. Ensure it doesn't already exist
    #
    # @param fullpath [String] - the full path where the file should be created
    # @param filename [String] - the filename to create
    # @return [String] - the absolute pathname of the file
    def create_csv_file(fullpath, filename, file_contents)
      fullname = File.join(fullpath, filename)

      raise IOError("#{fullname} already exists. It needs to be created but cannot.") if File.exist?(fullname)
      File.open(fullname, 'w') do |csv_file|
        csv_file.puts file_contents
      end
      File.absolute_path(fullname)
    end


    def remove_file(dir, filename)
      fullname = File.join(dir, filename)
      File.delete(fullname) if File.exist?(fullname)
    end

  end
end
