require 'rails_helper'

class PageMetaImageTagsSetterTestController < ApplicationController
  include PageMetaImageTagsSetter
end


RSpec.describe PageMetaImageTagsSetterTestController, type: :controller do

  MOCK_BASE_URL   = 'http://test.host'
  MOCK_REQ_PATH   = '/test-path'
  MOCK_ASSET_PATH = '/assets'

  let(:expected_base_url) { "#{MOCK_BASE_URL}#{MOCK_ASSET_PATH}/" }

  let(:default_title)  { SiteMetaInfoDefaults.title } #{ 'Hitta H-märkt hundföretag, hundinstruktör' }
  let(:default_full_title) { "#{SiteMetaInfoDefaults.title} | #{SiteMetaInfoDefaults.site_name}" }
  let(:default_desc) { SiteMetaInfoDefaults.description }
  let(:default_keywords) { SiteMetaInfoDefaults.keywords }
  let(:default_image_filename) { SiteMetaInfoDefaults.image_filename }
  let(:default_image_url) { "http://test.host/assets/#{default_image_filename}" }
  let(:default_image_width) { SiteMetaInfoDefaults.image_width }
  let(:default_image_height) { SiteMetaInfoDefaults.image_height }
  let(:default_image_type) { "image/#{SiteMetaInfoDefaults.image_type}" }


  before(:all) do
    @orig_locale = I18n.locale

    @meta_image_setter = PageMetaImageTagsSetterTestController.new
    @meta_image_setter.set_request! ActionDispatch::TestRequest.create
    @meta_image_setter.request.path = MOCK_REQ_PATH

  end

  after(:all) { I18n.locale = @orig_locale }


  describe 'set_page_meta_images' do

    context 'looks up filename from the locale and gets the characteristics' do

      before(:all) do
        # temporarily add this file to the assets/images path
        @test_filename         = 'image.png'
        @asset_images_filepath = File.absolute_path(File.join(Rails.root, 'app', 'assets', 'images', @test_filename))
        @test_filename_url = /http:\/\/test.host\/assets\/image.png/

        @default_filename_url = /http:\/\/test.host\/assets\/#{I18n.t('meta.default.image_src')}/

        FileUtils.copy_file(file_fixture('image.png'), @asset_images_filepath)
      end

      after(:all) do
        FileUtils.remove_file(@asset_images_filepath)
      end


      describe 'image filename and url is given' do

        it 'uses the filename and provided url' do

          expect(@meta_image_setter).to receive(:set_page_meta_image_tags)
                                      .with(@test_filename_url,
                                            'png',
                                            width:  80,
                                            height: 80)

          @meta_image_setter.set_page_meta_images(@asset_images_filepath, @test_filename_url)
        end


        it 'if filename is not found, falls back to locale, then DEFAULT image' do

          expect(@meta_image_setter).to receive(:set_page_meta_image_tags)
                                      .with(@default_filename_url,
                                            SiteMetaInfoDefaults.image_type,
                                            width:  SiteMetaInfoDefaults.image_width,
                                            height: SiteMetaInfoDefaults.image_height)

          @meta_image_setter.set_page_meta_images("blorfo-#{Time.now.to_i}", @test_filename_url)
        end

      end


      describe 'no image filename is given' do

        it 'first tries to look up filename from the locale and gets the characteristics' do
          allow(I18n.config.backend).to receive(:exists?)
                                            .with(:sv, '.meta.image_src')
                                            .and_return(true)
          allow(I18n.config.backend).to receive(:translate)
                                            .with(:sv, 'page_meta_image_tags_setter_test..meta.image_src', anything)
                                            .and_return(@test_filename)

          expect(@meta_image_setter).to receive(:set_page_meta_image_tags)
                                      .with(@test_filename_url,
                                            'png',
                                            width:  80,
                                            height: 80)
          @meta_image_setter.set_page_meta_images
        end


        it 'uses the default meta-image if no locale entry is found' do

          expect(@meta_image_setter).to receive(:set_page_meta_image_tags)
                                      .with(@default_filename_url,
                                            SiteMetaInfoDefaults.image_type,
                                            width:  SiteMetaInfoDefaults.image_width,
                                            height: SiteMetaInfoDefaults.image_height)
          @meta_image_setter.set_page_meta_images
        end

      end


      it 'sets the OpenGraph info' do
        allow(I18n.config.backend).to receive(:exists?)
                                          .with(:sv, '.meta.image_src')
                                          .and_return(true)
        allow(I18n.config.backend).to receive(:translate)
                                          .with(:sv, 'page_meta_image_tags_setter_test..meta.image_src', anything)
                                          .and_return(@test_filename)

        @meta_image_setter.set_page_meta_images
        @meta_og_tags = @meta_image_setter.send(:meta_tags)['og']

        puts("@meta_og_tags_set = #{@meta_og_tags.inspect}")

        expect(@meta_og_tags['image']['_']).to eq "#{expected_base_url}#{@test_filename}"
        expect(@meta_og_tags['image']['type']).to eq 'image/png'
        expect(@meta_og_tags['image']['width']).to eq 80
        expect(@meta_og_tags['image']['height']).to eq 80
      end
    end

  end


  describe 'set_page_meta_image_tags(image_filename, image_type, width: 0, height: 0)' do

    let(:image_fn) { 'image.png' }
    let(:expected_image_url) { "#{expected_base_url}#{image_fn}" }


    it 'uses set_meta_tags to set image_src and og:image, og:image:width, height, type' do

      expect(subject).to receive(:set_meta_tags)
                             .with({ image_src: expected_image_url,
                                     og:        {
                                         image: {
                                             _:      expected_image_url,
                                             width:  80,
                                             height: 80,
                                             type:   'image/png'
                                         }
                                     }
                                   })

      subject.set_page_meta_image_tags(expected_image_url, 'png', width: 80, height: 80)
    end

    it 'default image width = 0 if not specified' do
      expect(subject).to receive(:set_meta_tags)
                             .with({ image_src: expected_image_url,
                                     og:        {
                                         image: {
                                             _:      expected_image_url,
                                             width:  0,
                                             height: 80,
                                             type:   'image/png'
                                         }
                                     }
                                   })

      subject.set_page_meta_image_tags(expected_image_url, 'png', height: 80)
    end

    it 'default image height = 0 if not specified' do
      expect(subject).to receive(:set_meta_tags)
                             .with({ image_src: expected_image_url,
                                     og:        {
                                         image: {
                                             _:      expected_image_url,
                                             width:  80,
                                             height: 0,
                                             type:   'image/png'
                                         }
                                     }
                                   })

      subject.set_page_meta_image_tags(expected_image_url, 'png', width: 80)
    end

  end



end
