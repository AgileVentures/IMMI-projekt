require 'rails_helper'

RSpec.describe Adapters::AddressToSchemaGeoCoordinates do

  let(:test_adapter) {
    co   = create(:company)
    addr = co.addresses.first
    Adapters::AddressToSchemaGeoCoordinates.new(addr)
  }


  it 'target_class' do
    expect(test_adapter.target_class).to eq SchemaDotOrg::GeoCoordinates
  end


  it 'set_target_attributes' do
    schema_org = test_adapter.set_target_attributes(test_adapter.target_class.new)

    expect(schema_org.latitude).to eq 56.7422437
    expect(schema_org.longitude).to eq 12.7206453

  end

end
