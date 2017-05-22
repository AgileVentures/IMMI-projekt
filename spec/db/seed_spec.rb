require 'rails_helper'

RSpec.describe 'load admin.email and admin.password from ENV in production' do

  env_shf_email = 'SHF_ADMIN_EMAIL'
  env_shf_pwd = 'SHF_ADMIN_PWD'
  admin_email = 'the-shfadmin@shf.org'
  admin_pwd = 'insecure-password'

  SEED_ERROR = 'Seed ERROR: Could not load either admin email or password. NO ADMIN was created!'


  describe 'happy path - all is valid' do

    before(:each) do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      stub_const('ENV', {env_shf_email => admin_email, env_shf_pwd => admin_pwd})
      SHFProject::Application.load_tasks
      SHFProject::Application.load_seed
    end

    let(:admin_in_db) { User.find_by_email(admin_email) }

    it "#{admin_email} is in the db" do
      expect(admin_in_db).not_to be_nil
    end

    it "#{admin_email} is an admin (admin=true) in db" do
      expect(admin_in_db.admin).to be_truthy
    end

    it "admin email is = ENV['SHF_ADMIN_EMAIL']" do
      expect(admin_in_db.email).to eq(admin_email)
    end

    it "admin email is = ENV['SHF_ADMIN_PWD']" do
      # User.find(1).valid_password?('password123')
      expect(admin_in_db.valid_password?(admin_pwd)).to be_truthy
    end

  end


  describe 'sad path - things go wrong' do

    before(:each) do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    end

    it "ENV[#{env_shf_email}] not found" do
      stub_const('ENV', {env_shf_pwd => admin_pwd})

      expect { Rails.application.load_seed }.to raise_exception SEED_ERROR
    end

    it "ENV[#{env_shf_email}] is an empty string" do
      stub_const('ENV', {env_shf_email => '', env_shf_pwd => admin_pwd})

      expect { Rails.application.load_seed }.to raise_exception SEED_ERROR
    end

    it "ENV[#{env_shf_pwd}] not found" do
      stub_const('ENV', {env_shf_email => admin_email})

      expect { Rails.application.load_seed }.to raise_exception SEED_ERROR
    end

    it "ENV[#{env_shf_pwd}] is an empty string" do
      stub_const('ENV', {env_shf_email => admin_email, env_shf_pwd => ''})

      expect { Rails.application.load_seed }.to raise_exception SEED_ERROR
    end
  end

end
