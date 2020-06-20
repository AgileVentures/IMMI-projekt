require 'rails_helper'
require 'shared_context/mock_app_configuration'


RSpec.describe MetaTagsHelper, type: :helper do

  MOCK_BASE_URL   = 'http://test.host' unless defined?(MOCK_BASE_URL)
  MOCK_REQ_PATH   = '/test-path' unless defined?(MOCK_REQ_PATH)

  let(:default_keywords) { AdminOnly::AppConfiguration.config_to_use.site_meta_keywords }

  describe 'meta_tags_for_url_path returns a Hash with tag info' do

    it 'uses info from AdminOnly::AppConfig.config_to_use' do

      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_name).twice.and_call_original # called to get the full site title
      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_title).twice.and_call_original
      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_keywords).and_call_original
      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_description).and_call_original

      # stub these methods
      expect(helper).to receive(:og_meta_tags).and_return({})
      expect(helper).to receive(:facebook_meta_tags).and_return({})
      expect(helper).to receive(:twitter_meta_tags).and_return({})
      expect(helper).to receive(:meta_image_tags).and_return({})

      expect(helper.meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)).to eq({ description: "site meta description",
                                                                                  keywords:    "site meta keywords",
                                                                                  og: {},
                                                                                  site:        "site name",
                                                                                  title:       "site title" })
    end


    it 'sets the Facebook OpenGraph (og) tags' do
      expect(helper).to receive(:og_meta_tags).with({ base_url:    "http://test.host",
                                                          description: "site meta description",
                                                          fullpath:    "/test-path",
                                                          site_name:   "site name",
                                                          title:       "site title | site name",
                                                          type:        "og type" }).and_call_original

      # stub these methods
      expect(helper).to receive(:facebook_meta_tags).and_return({})
      expect(helper).to receive(:twitter_meta_tags).and_return({})
      expect(helper).to receive(:meta_image_tags).and_return({})

      expect(helper.meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)).to eq({ description: "site meta description",
                                                                                  keywords:    "site meta keywords",
                                                                                  og: { description: "site meta description",
                                                                                        locale: "sv_SE",
                                                                                        site_name: "site name",
                                                                                        title: "site title | site name",
                                                                                        type: "og type",
                                                                                        url: "http://test.host/test-path" },
                                                                                  site:        "site name",
                                                                                  title:       "site title" })
    end


    it 'sets the facebook tags (the Facebook Application id) from AppConfiguration' do
      expect(helper).to receive(:facebook_meta_tags).and_call_original

      # stub these methods
      expect(helper).to receive(:og_meta_tags).and_return({})
      expect(helper).to receive(:twitter_meta_tags).and_return({})
      expect(helper).to receive(:meta_image_tags).and_return({})

      helper.meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)
    end


    it 'sets the twitter tags' do
      expect(helper).to receive(:twitter_meta_tags).and_call_original

      # stub these methods
      expect(helper).to receive(:og_meta_tags).and_return({})
      expect(helper).to receive(:facebook_meta_tags).and_return({})
      expect(helper).to receive(:meta_image_tags).and_return({})

      helper.meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)
    end


    it 'appends Business Categories to the AdminOnlyAppConfig site_meta_keywords, categories are sorted by name' do

      create(:business_category, name: 'category2')
      create(:business_category, name: 'category1')

      # stub these methods
      expect(helper).to receive(:og_meta_tags).and_return({})
      expect(helper).to receive(:meta_image_tags).and_return({})
      expect(helper).to receive(:facebook_meta_tags).and_return({})
      expect(helper).to receive(:twitter_meta_tags).and_return({})

      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:site_meta_keywords)
                                                               .twice
                                                               .and_return('these are the site keywords')

      expect(helper.meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)).to eq({ description: "site meta description",
                                                                                  keywords:    "#{AdminOnly::AppConfiguration.config_to_use.site_meta_keywords}, category1, category2",
                                                                                  og: {},
                                                                                  site:        "site name",
                                                                                  title:       "site title" })
    end

  end


  describe 'facebook_meta_tags' do

    it 'default is AdminOnly::AppConfiguration.facebook_app_id' do
      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:facebook_app_id)
      helper.facebook_meta_tags
    end

    it 'can specify the app_id' do
      expect(AdminOnly::AppConfiguration.config_to_use).not_to receive(:facebook_app_id)
      expect(helper.facebook_meta_tags(app_id: 987654321)).to eq({ fb: { app_id: 987654321 } })
    end
  end


  describe 'twitter_meta_tags' do

    it 'returns a hash with AdminOnly::AppConfiguration.twitter_card_type' do
      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:twitter_card_type).twice
      expect(helper.twitter_meta_tags).to eq({ twitter: { card: AdminOnly::AppConfiguration.config_to_use.twitter_card_type } })
    end

    it "can specify the twitter card type in the hash" do
      expect(AdminOnly::AppConfiguration.config_to_use).not_to receive(:twitter_card_type)
      expect(helper.twitter_meta_tags(card: 'blorf')).to eq({ twitter: { card: 'blorf' } })
    end
  end


  describe 'meta_robots_none' do

    it 'returns hash for nofollow and noindex, both set to true' do
      expect(helper.meta_robots_none).to eq({ nofollow: true, noindex: true })
    end
  end


end
