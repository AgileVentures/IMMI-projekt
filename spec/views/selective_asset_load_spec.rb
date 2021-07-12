require 'rails_helper'

RSpec.describe 'selective loading of external assets on specific pages' do

  before(:each) { view.lookup_context.prefixes +=
                   ['application', 'companies', 'shf_documents'] }

  describe 'ckeditor.js' do
    let(:document) { create(:shf_document, :txt) }
    let(:company)  { create(:company) }

    it 'is loaded on companies/edit' do
      allow(view).to receive(:current_user) { Visitor.new }
      assign(:company, company)

      stub_template 'business_categories/_as_list' => ''
      render template: 'companies/edit', layout: 'layouts/application'

      expect(rendered).to have_xpath("//head/script[contains(@src,'ckeditor.js')]",
                                     visible: false)
    end

    it 'is loaded on shf_documents/contents_edit' do
      allow(view).to receive(:current_user) { Visitor.new }
      assign(:page, document.actual_file_file_name)
      assign(:title, document.title)
      assign(:contents, 'This is the document contents')

      stub_template 'shf_documents/_contents_form' => ''
      render template: 'shf_documents/contents_edit', layout: 'layouts/application'

      expect(rendered).to have_xpath("//head/script[contains(@src,'ckeditor.js')]",
                                     visible: false)
    end

    it 'is not loaded on other pages' do
      allow(view).to receive(:current_user) { Visitor.new }
      assign(:company, company)
      assign(:shf_document, document)

      without_partial_double_verification do
        # http://rspec.info/blog/2017/05/rspec-3-6-has-been-released/
        allow(view).to receive(:policy).and_return(double('cmpy policy',
                                                          update?: false,
                                                          index?: false,
                                                          destroy?: false,
                                                          view_complete_status?: false))

        stub_template 'business_categories/_as_list' => ''
        stub_template 'companies/_branding_payment_status' => ''
        stub_template 'companies/_map_companies' => ''
        stub_template 'companies/_company_members' => ''
        stub_template 'companies/_company_addresses' => ''
        stub_template 'companies/_edit_branding_modal' => ''

        render template: 'companies/show', layout: 'layouts/application'
        expect(rendered).not_to have_xpath("//head/script[contains(@src,'ckeditor.js')]",
                                           visible: false)

        render template: 'shf_documents/show', layout: 'layouts/application'
        expect(rendered).not_to have_xpath("//head/script[contains(@src,'ckeditor.js')]",
                                           visible: false)
      end
    end
  end
end
