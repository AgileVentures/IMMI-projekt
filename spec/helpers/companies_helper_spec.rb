require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do
  let!(:company) { create(:company) }

  describe '#company_complete?' do
    it 'returns false if company is nil' do
      expect(helper.company_complete?(nil)).to eq false
    end

    it 'returns false if company name is nil' do
      company.name = nil
      expect(helper.company_complete?(company)).to eq false
    end

    it 'returns false if company region is nil' do
      company.region = nil
      expect(helper.company_complete?(company)).to eq false
    end

    it 'returns false is company name or region is empty string' do
      company.name = ''
      expect(helper.company_complete?(company)).to eq false
    end

    it 'returns true if company name and region are non-empty string' do
      expect(helper.company_complete?(company)).to eq true
    end

  end

  describe 'companies' do
    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let!(:ma1) do
      ma = create(:membership_application, user: employee1,
                  status: 'Godkänd', company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat1')
      ma
    end
    let!(:ma2) do
      ma = create(:membership_application, user: employee2,
                  status: 'Godkänd', company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat2')
      ma
    end
    let!(:ma3) do
      ma = create(:membership_application, user: employee3,
                  status: 'Godkänd', company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat3')
      ma
    end

    before(:all) do
      Company.delete_all
      MembershipApplication.delete_all
      User.delete_all
    end

    it '#last_category_name' do
      expect(helper.last_category_name(company)).to eq 'cat3'
    end

    it '#list_categories' do
      expect(helper.list_categories(company)).to eq 'cat1 cat2 cat3'
      expect(helper.list_categories(company)).not_to include 'Träning'
    end
  end
end
