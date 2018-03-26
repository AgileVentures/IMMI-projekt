require 'rails_helper'

RSpec.describe 'load business categories, regions, kommuns, users and applications from ENV in production' do

  # seed with a minimum of 4 users to cover: admin, no application, single application, double application
  seed_users = 4

  env_shf_email = 'SHF_ADMIN_EMAIL'
  env_shf_pwd = 'SHF_ADMIN_PWD'
  admin_email = 'the-shfadmin@shf.org'
  admin_pwd = 'insecure-password'

  before(:all) do
    DatabaseCleaner.start
    RSpec::Mocks.with_temporary_scope do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      stub_const('ENV', { 'SHF_SEED_USERS' => seed_users.to_s,
                          env_shf_email => admin_email,
                          env_shf_pwd => admin_pwd })
      SHFProject::Application.load_tasks
      SHFProject::Application.load_seed
    end
  end

  after(:all) do
    DatabaseCleaner.clean
    Rake::Task['shf:load_regions'].reenable
    Rake::Task['shf:load_kommuns'].reenable
  end

  it "business categories are in the db" do
    expect(BusinessCategory.all.size).to eq(11)
  end

  it "regions are in the db" do
    expect(Region.all.size).to eq(23)
  end

  it "kommuns are in the db" do
    expect(Kommun.all.size).to eq(290)
  end

  it "users are in the db" do
    expect(User.all.size).to eq(seed_users)
  end

  it "addresses are in the db" do
    expect(Address.count).to eq(ShfApplication.count)
  end

  it "companies are in the db" do
    expect(Company.count).to eq(ShfApplication.count)
  end

  it "memberships applications are in the db" do
    expect(ShfApplication.all.size).to eq(seed_users-1)
  end

end
