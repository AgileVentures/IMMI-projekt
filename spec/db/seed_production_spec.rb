require 'rails_helper'

require File.join(__dir__, 'shared_specs_db_seeding')

ENV_ADMIN_EMAIL_KEY = 'SHF_ADMIN_EMAIL'
ENV_ADMIN_PASSWORD_KEY = 'SHF_ADMIN_PWD'

RSpec.describe 'Production db is seeded with minimal info' do

  admin_email = 'the-shfadmin@shf.org'
  admin_pwd = 'insecure-password'


  it_behaves_like 'admin, business categories, kommuns, and regions are seeded', 'production', admin_email, admin_pwd


  describe 'happy path - all is valid' do

    before(:all) do
      DatabaseCleaner.start
      RSpec::Mocks.with_temporary_scope do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => admin_email,
                                             ENV_ADMIN_PASSWORD_KEY => admin_pwd}) )
        SHFProject::Application.load_tasks
        SHFProject::Application.load_seed
      end
    end

    after(:all) do
      DatabaseCleaner.clean
      Rake::Task['shf:load_regions'].reenable
      Rake::Task['shf:load_kommuns'].reenable
    end

    let(:admin_in_db) { User.find_by_email(admin_email) }


    it 'admin is the only user in the db' do
      expect(User.all.size).to eq(1)
    end

    it 'adresses are not in the db' do
      expect(Address.all.size).to eq(0)
    end

    it 'companies are not in the db' do
      expect(Company.all.size).to eq(0)
    end

    it 'memberships applications are not in the db' do
      expect(ShfApplication.all.size).to eq(0)
    end

  end

end
