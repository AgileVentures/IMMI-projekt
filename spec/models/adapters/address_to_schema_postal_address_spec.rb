require 'rails_helper'

RSpec.describe Adapters::AddressToSchemaPostalAddress do

  let(:test_adapter) {
    co = create(:company)
    addr = co.addresses.first
    Adapters::AddressToSchemaPostalAddress.new(addr)
  }


  it 'target_class' do
    expect(test_adapter.target_class).to eq SchemaDotOrg::PostalAddress
  end


  it 'set_target_attributes' do
    schema_org = test_adapter.set_target_attributes(test_adapter.target_class.new)

    expect(schema_org.streetAddress).to eq 'Hundforetagarevägen 1'
    expect(schema_org.postalCode).to eq '310 40'
    expect(schema_org.addressRegion).to eq 'MyString'
    expect(schema_org.addressLocality).to eq 'Harplinge'
    expect(schema_org.addressCountry).to eq 'Sverige'

  end

end
