require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do
  let!(:company) { create(:company) }

  describe 'companies' do
    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let!(:ma1) do
      ma = create(:membership_application, :accepted,
                  user: employee1,
                  company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat1')
      ma
    end
    let!(:ma2) do
      ma = create(:membership_application, :accepted,
                  user: employee2,
                  company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat2')
      ma
    end
    let!(:ma3) do
      ma = create(:membership_application, :accepted,
                  user: employee3,
                  company_number: company.company_number)
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
