require 'rails_helper'


RSpec.describe 'route to the hbrand image for a company', type: :routing do

  describe '#url_for_co_hbrand_image' do

    let(:co) { create(:company, description: 'description') }
    let(:test_adapter) { Adapters::CompanyToSchemaLocalBusiness.new(co) }

    it 'path to the image (hbrand image) is valid'  do
      schema_org = test_adapter.set_target_attributes(test_adapter.target_class.new)

      expect(schema_org.image).to match(/\/hundforetag\/#{co.id}\/company_h_brand/)
      assert_recognizes({controller: 'companies', action: 'company_h_brand', id: "#{co.id}"}, "hundforetag/#{co.id}/company_h_brand")
    end

  end

end
