require 'rails_helper'
require 'shared_context/mock_app_configuration'


RSpec.describe MetaOgTagsHelper, type: :helper do

  before(:each) do
    I18n.locale  = :sv
  end

  it 'defaults to AdminOnly::AppConfig.config_to_use values' do

    expect(MockAppConfig).to receive(:site_name).twice.and_call_original # called to get the full site title
    expect(MockAppConfig).to receive(:site_meta_title).and_call_original
    expect(MockAppConfig).to receive(:site_meta_description).and_call_original
    expect(MockAppConfig).to receive(:og_type).and_call_original

    expect_any_instance_of(ActionView::Base).to receive(:set_meta_tags)
                                                    .with({ og: { description: "site meta description",
                                                                  locale:      "sv_SE",
                                                                  site_name:   "site name",
                                                                  title:       "site title | site name",
                                                                  type:        "og type",
                                                                  url:         "/" } })
                                                    .and_call_original

    helper.set_og_meta_tags
  end


  describe 'locale is the I18n.locale plus country string' do

    it "locale :sv = 'sv_SE'" do
      I18n.locale = :sv

      #set_the_meta_tags
      helper.set_og_meta_tags

      expect(helper.send(:meta_tags)
                 .send(:meta_tags)[:og][:locale]).to eq("sv_SE")
    end

    it "locale :en = 'en_US'" do
      I18n.locale = :en

      helper.set_og_meta_tags

      expect(helper.send(:meta_tags)
                 .send(:meta_tags)[:og][:locale]).to eq("en_US")
    end
  end


  it 'uses any argument values passed in' do

    expect(MockAppConfig).not_to receive(:site_name)
    expect(MockAppConfig).not_to receive(:site_meta_title)
    expect(MockAppConfig).not_to receive(:site_meta_description)
    expect(MockAppConfig).not_to receive(:og_type)

    expect_any_instance_of(ActionView::Base).to receive(:set_meta_tags)
                                                    .with({ og: { description: "this description",
                                                                  locale:      "sv_SE",
                                                                  site_name:   "this name",
                                                                  title:       "this title",
                                                                  type:        "this type",
                                                                  url:         "http:://base:urlfull/path/to/img" } })
    helper.set_og_meta_tags(site_name:   'this name',
                            title:       'this title',
                            description: 'this description',
                            type:        'this type',
                            base_url:    'http:://base:url',
                            fullpath:    'full/path/to/img')
  end

end
