require 'rails_helper'

class PageMetaOgTagsSetterTestController < ApplicationController
  include PageMetaOgTagsSetter
end


RSpec.describe PageMetaOgTagsSetterTestController, type: :controller do

  MOCK_BASE_URL   = 'http://test.host'
  MOCK_REQ_PATH   = '/test-path'


  before(:all) do
    @orig_locale = I18n.locale

    @meta_setter = PageMetaOgTagsSetterTestController.new
    @meta_setter.set_request! ActionDispatch::TestRequest.create
    @meta_setter.request.path = MOCK_REQ_PATH

  end

  after(:all) { I18n.locale = @orig_locale }


  describe 'set_og_meta_tags (Facebook OpenGraph))' do

    describe 'defaults' do

      before(:all) do
        I18n.locale = :sv
        @meta_setter.set_og_meta_tags
        @meta_tags_set = @meta_setter.send(:meta_tags)['og']
      end

      it 'site_name' do
        expect(@meta_tags_set['site_name']).to eq SiteMetaInfoDefaults.site_name
      end

      it 'title' do
        expect(@meta_tags_set['title']).to eq "#{SiteMetaInfoDefaults.title} | #{SiteMetaInfoDefaults.site_name}"
      end

      it 'description' do
        expect(@meta_tags_set['description']).to eq SiteMetaInfoDefaults.description
      end
      it 'type' do
        expect(@meta_tags_set['type']).to eq SiteMetaInfoDefaults.og_type
      end
    end


    describe 'argument values passed in' do

      before(:all) do
        I18n.locale = :sv
        @meta_setter.set_og_meta_tags(site_name: 'site name',
                                      title:       'page title',
                                      description: 'page description',
                                      type:        'the page type',
                                      base_url:    MOCK_BASE_URL,
                                      fullpath:    MOCK_REQ_PATH)
        @meta_tags_set = @meta_setter.send(:meta_tags)['og']
      end

      it 'site_name' do
        expect(@meta_tags_set['site_name']).to eq 'site name'
      end


      it 'title' do
        expect(@meta_tags_set['title']).to eq 'page title'
      end

      it 'description' do
        expect(@meta_tags_set['description']).to eq 'page description'
      end

      it 'type' do
        expect(@meta_tags_set['type']).to eq 'the page type'
      end

      it 'locale' do
        expect(@meta_tags_set['locale']).to eq 'sv_SE'
      end

    end

  end


end
