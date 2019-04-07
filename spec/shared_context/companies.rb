# This will create 7 companies:
#
#  complete_co1 - has 2 branding payments
#  complete_co2 - just has a company name, number, and the company Factory defaults
#  co_no_viz_addresses - a company with just 1 address with visibility: none, and the company Factory defaults
#  company_3_addrs - has 3 addresses (via the Factory) and 2 events
#  co_with_short_h_brand_url - company with a short_h_brand_url, and company Factory defaults
#  co_no_name - name is an empty String, and company Factory defaults
#  co_nil_region - the region is set to nil, and company Factory defaults
#
# These can be used in tests by requiring this file,
#   and putting "include_context 'create companies'" in an example section or RSpec
#
RSpec.shared_context 'create companies' do

  let(:complete_co1) do
    co1 = create(:company, name: 'Complete Company 1',
           description:    'This co has a 2 branding payments',
           company_number: '4268582063')
    # this ensures we have an application and business categories for the company
    create(:shf_application, :accepted, company_number: co1.company_number, num_categories: 3)
    co1
  end
  let(:payment1_co1) do
    start_date, expire_date = Company.next_branding_payment_dates(complete_co1.id)
    create(:payment,
           :successful,
           user:         user,
           company:      complete_co1,
           payment_type: Payment::PAYMENT_TYPE_BRANDING,
           notes:        'these are notes for branding payment1_co1, complete_co1',
           start_date:   start_date,
           expire_date:  expire_date)
  end
  let(:payment2) do
    start_date, expire_date = Company.next_branding_payment_dates(complete_co1.id)
    create(:payment,
           :successful,
           user:         user,
           company:      complete_co1,
           payment_type: Payment::PAYMENT_TYPE_BRANDING,
           notes:        'these are notes for branding payment2',
           start_date:   start_date,
           expire_date:  expire_date)
  end


  let(:complete_co2) do
    create(:company, name: 'Complete Company 2',
           company_number: '5560360793')
  end


  let(:co_no_viz_addresses) do
    co = create(:company, name: 'Complete Company 3',
                description:    'this company has no addresses',
                company_number: '5569467466', num_addresses: 0)
    create(:address, visibility: 'none', addressable: co)
    co.save!
    co
  end


  let(:company_3_addrs) do
    create(:company, num_addresses: 3,
           description:             'this co has 3 addresses and 2 events')
  end
  let(:event1) { create(:event, company: company_3_addrs) }
  let(:event2) { create(:event, company: company_3_addrs) }


  let(:co_with_short_h_brand_url) do
    create(:company, short_h_brand_url: 'http://www.tinyurl.com/hbrand')
  end


  let(:co_no_name) do
    create(:company, name: '', company_number: '2120000142')
  end


  let(:co_nil_region) do
    nil_co    = create(:company, name: 'Nil Region',
                       company_number: '6112107039')
    no_region = build(:company_address, addressable: nil_co, region: nil)
    no_region.save(validate: false)

    nil_co
  end

end
