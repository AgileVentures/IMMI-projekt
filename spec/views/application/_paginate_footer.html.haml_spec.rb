require 'rails_helper'

RSpec.describe 'companies/index' do
  let(:paginate_class) { 'companies_pagination' }
  let(:companies)      { Company.ransack.result.page('1').per_page(10) }
  let(:items_count)    { 10 }
  let(:url)            { companies_path }

  before(:each) do
    75.times do |n|
      company = FactoryGirl.build(:company, company_number: "#{n}")
      company.save!(validate: false)
    end

    render partial: 'application/paginate_footer',
           locals: { entities: companies, paginate_class: paginate_class,
                     items_count: items_count, url: url }
  end

  it 'renders paginate links with data-remote attributes' do
    # should have 8 links for specific pages
    rx = /<a .*data-remote="true" href="\/hundforetag\?page=\d{1}"/

    expect(rendered).to match rx
    expect(rendered).to match(/page=1/)
    expect(rendered).to match(/page=8/)
    expect(rendered).to_not match(/page=9/)

    # should have link for "previous"
    rx = /<a data-remote="true" href="#">« Föregående/
    expect(rendered).to match rx

    # should have link for "next"
    rx = /<a data-remote="true" rel="next" href="\/hundforetag\?page=2">Nästa »/
    expect(rendered).to match rx
  end

end
