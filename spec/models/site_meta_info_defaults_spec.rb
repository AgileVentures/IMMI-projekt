require 'rails_helper'


RSpec.describe SiteMetaInfoDefaults do

  subject { SiteMetaInfoDefaults }


  # see https://github.com/rspec/rspec-mocks/issues/663 for more info on why
  # you cannot just stub I18n.t()


  it "site_name is I18n.t('SHF_name')" do
    allow(I18n.config.backend).to receive(:translate)
                                      .with(:sv, 'SHF_name', anything)
                                      .and_return('site name from I18n')
    expect(subject.site_name).to eq 'site name from I18n'
  end

  it "title is I18n.t('meta.default.title')" do
    allow(I18n.config.backend).to receive(:translate)
                                      .with(:sv, 'meta.default.title', anything)
                                      .and_return('default title from I18n')
    expect(subject.title).to eq 'default title from I18n'
  end

  it "description is I18n.t('meta.default.description')" do
    allow(I18n.config.backend).to receive(:translate)
                                      .with(:sv, 'meta.default.description', anything)
                                      .and_return('default description from I18n')
    expect(subject.description).to eq 'default description from I18n'
  end

  it "keywords is I18n.t('meta.default.keywords')" do
    allow(I18n.config.backend).to receive(:translate)
                                      .with(:sv, 'meta.default.keywords', anything)
                                      .and_return('default keywords from I18n')
    expect(subject.keywords).to eq 'default keywords from I18n'
  end

  it "image_filename is I18n.t('meta.default.image_src')" do
    allow(I18n.config.backend).to receive(:translate)
                                      .with(:sv, 'meta.default.image_src', anything)
                                      .and_return('default image_src from I18n')
    expect(subject.image_filename).to eq 'default image_src from I18n'
  end

  it 'image_type is jpeg' do
    expect(subject.image_type).to eq 'jpeg'
  end

  it 'image_width is 1245' do
    expect(subject.image_width).to eq 1245
  end

  it 'image_height is 620' do
    expect(subject.image_height).to eq 620
  end

  it "og_type is 'website'" do
    expect(subject.og_type).to eq 'website'
  end


  describe 'Facebook app id' do

    env_key =  'SHF_FB_APPID'

    it "Facebook App id is ENV['#{env_key}']" do

      # stub the value
      RSpec::Mocks.with_temporary_scope do
        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash.merge({ env_key => '123321' }))

        expect(subject.facebook_app_id).to eq(123321)

      end
    end


    it "is 0 if ENV['#{env_key}'] does not exist" do

      # stub the value
      RSpec::Mocks.with_temporary_scope do
        orig_id = ENV.fetch(env_key, nil)

        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash)
        ENV.delete(env_key)

        expect(subject.facebook_app_id).to eq(0)
        ENV[env_key] = orig_id if orig_id
      end
    end

  end


  it "twitter_card_type is 'summary'" do
    expect(subject.twitter_card_type).to eq 'summary'
  end


  describe '.use_default_if_blank' do

    it 'is the value if value is not blank' do
      expect(subject.use_default_if_blank(:blorf, 'this is not blank')).to eq 'this is not blank'
    end

    it 'uses the method if the value is blank' do
      expect(subject).to receive(:site_name).and_return('this is the site name')
      subject.use_default_if_blank(:site_name, '')
    end
  end

end
