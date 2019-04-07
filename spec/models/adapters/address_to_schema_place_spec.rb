require 'rails_helper'

RSpec.describe Adapters::AddressToSchemaPlace do

  let(:test_adapter) {
    co = create(:company)
    addr = co.addresses.first
    Adapters::AddressToSchemaPlace.new(addr)
  }


  it 'target_class' do
    expect(test_adapter.target_class).to eq SchemaDotOrg::Place
  end


  it 'set_target_attributes' do
    schema_org = test_adapter.set_target_attributes(test_adapter.target_class.new)

    expect(schema_org.address.streetAddress).to eq 'Hundforetagarevägen 1'
    expect(schema_org.address.postalCode).to eq '310 40'
    expect(schema_org.address.addressRegion).to eq 'MyString'
    expect(schema_org.address.addressLocality).to eq 'Harplinge'
    expect(schema_org.address.addressCountry).to eq 'Sverige'
    expect(schema_org.geo.latitude).to eq 56.7422437
    expect(schema_org.geo.longitude).to eq 12.7206453

  end

end
