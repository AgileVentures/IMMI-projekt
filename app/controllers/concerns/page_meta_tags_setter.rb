#!/usr/bin/ruby

require 'mini_magick'

#--------------------------
#
# @module PageMetaInfoSetter
#
# @desc Responsibility: Sets the meta tags for a page using locale files.
#       Falls back to site defaults if an entry is not found
#       in the locale files.
#
# @example In the CompaniesController, use the defaults for the :index action
#     but set the title tag specifically for a company that is being displayed
#     with the :show action.
#      (Note there really would be more meta-tag info set for a Company.)
#     Set nofollow and noindex to true for the
#     :edit action with the :set_page_meta_robots_none method
#
#       class CompaniesController
#
#         include PageMetaInfoSetter
#
#         before_action :set_meta_tags_for_url_path, only: [:index, :show]
#         before_action :set_page_meta_robots_none, only: [:edit]
#
#         # No other code is needed for :index or :edit methods.
#
#
#         # Add this code in the :show method:
#         def show
#           ...
#           set_meta_tags title: @company.name
#           ...
#         end
#
#       end
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-07
#
# @file page_meta_info_setter.rb
#
#--------------------------


module PageMetaTagsSetter

  # needed so we can get the asset_url of the images needed for meta tags
  include ActionView::Helpers::AssetUrlHelper

  META_SITE_NAME = I18n.t('SHF_name')
  META_TITLE_DEFAULT    = I18n.t('meta.default.title')
  META_DESC_DEFAULT     = I18n.t('meta.default.description')
  META_KEYWORDS_DEFAULT = I18n.t('meta.default.keywords')

  META_OG_DEFAULT_TYPE  = 'website'
  META_TWITTER_CARDTYPE = 'summary'

  META_IMAGE_DEFAULT_FN     = I18n.t('meta.default.image_src')
  META_IMAGE_DEFAULT_TYPE   = 'jpeg'
  META_IMAGE_DEFAULT_WIDTH  = 1245
  META_IMAGE_DEFAULT_HEIGHT = 620

  # Rails I18n usually uses a 2 letter language codes for the locale.
  # But Facebook's OpenGraph ('og') requires a language code and country (region)
  # code per the IETF language standard  https://en.wikipedia.org/wiki/IETF_language_tag
  # This is a simple mapping to the locales we're using.  If we start supporting
  # more languages and/or regions, this can be made more complex.
  LOCALES_TO_IETF = { sv: 'sv_SE',
                      en: 'en_US'
  }

  LOCALE_TITLE_KEY        = '.meta.title'
  LOCALE_DESCRIPTION_KEY  = '.meta.description'
  LOCALE_TYPE_KEY         = '.meta.type'
  LOCALE_KEYWORDS_KEY     = '.meta.keywords'
  LOCALE_IMAGE_KEY        = '.meta.image_src'
  LOCALE_TWITTER_CARD_KEY = '.meta.twitter.card'


  # This sets the meta tags for a page. It can be used as a before_action
  # or other Controller callback method since it has no arguments.
  #
  # After this is called, a Controller or view can override or add to any of
  # the meta-tag information that this has set by calling :set_meta_tags again.
  #
  # This will get these meta tags from locale files:
  #   - title
  #   - description
  #   - keywords    (And will  append Business Categories to the keywords)
  #   - image_src
  #
  # If a locale entry isn't found, a default value will be used instead
  #
  def set_page_meta_tags
    req = self.request
    set_meta_tags_for_url_path(req.base_url, req.fullpath)
  end


  # Set the meta tags for a page that has the given url + fullpath.
  # The base_url and request fullpath are needed so that the full URL can
  # be put into meta tags (e.g. og.url)
  def set_meta_tags_for_url_path(base_url, request_fullpath)

    page_title = t(LOCALE_TITLE_KEY, default: META_TITLE_DEFAULT)
    page_desc  = t(LOCALE_DESCRIPTION_KEY, default: META_DESC_DEFAULT)

    full_title = meta_full_title(page_title)

    set_meta_tags site: META_SITE_NAME,
                  title:     page_title,
                  description: page_desc,
                  keywords:    create_keywords

    set_og_meta_tags(title: full_title,
                     description: page_desc,
                     type: t(LOCALE_TYPE_KEY, default: META_OG_DEFAULT_TYPE),
                     base_url: base_url,
                     fullpath: request_fullpath)

    set_twitter_meta_tags(card: t(LOCALE_TWITTER_CARD_KEY, default: META_TWITTER_CARDTYPE))
    set_page_meta_images
  end


  def set_og_meta_tags(title: meta_default_full_title,
                       description: META_DESC_DEFAULT,
                       type: META_OG_DEFAULT_TYPE,
                       base_url: self.request.base_url,
                       fullpath:  '/')

    set_meta_tags og: {
        title:       title,
        description: description,
        url:         base_url + fullpath,
        type:        type,
        locale:      meta_og_locale
    }
  end


  def set_twitter_meta_tags(card: 'summary')
    set_meta_tags twitter: {
        card: card
    }
  end


  # TODO: handle more than 1 image for a page. get possible comma sep. list from locale
  # Set meta tags for the page images.
  # If no filename is provided or if it doesn't exit,
  #   use the filename given in the locale file or the default.
  #
  def set_page_meta_images(full_image_filepath = nil, full_image_url = nil)

    if  full_image_filepath.nil? || !File.exist?(full_image_filepath)
      fallback_to_locale_or_default_image

    else
        # make a temp. copy of the file just to be safe
        image   = MiniMagick::Image.new(full_image_filepath)
        set_page_meta_image_tags(full_image_url,
                                 image.type.downcase,
                                 width:  image.width,
                                 height: image.height)
    end

  end


  # Look up the image file name in the locale file  under the
  # .meta.image_src key.
  # If no entry in the locale is found, use the default meta image
  def fallback_to_locale_or_default_image
    if I18n.exists?(LOCALE_IMAGE_KEY)
      set_page_meta_image_from_locale
    else
      set_page_meta_default_image_tags
    end
  end


  def set_page_meta_image_from_locale
    image_fn = t(LOCALE_IMAGE_KEY)
    image_absolute_path = File.join(Rails.root, 'app', 'assets', image_path(image_fn))

    # makes a temp. copy of the file
    image = MiniMagick::Image.new(image_absolute_path)

    image_url = asset_url("assets/#{image_fn}")
    set_page_meta_image_tags(image_url,
                             image.type.downcase,
                             width:  image.width,
                             height: image.height)
  end


  # Set the meta image tags for a page using the default image and tags
  def set_page_meta_default_image_tags
    image_url = asset_url("assets/#{META_IMAGE_DEFAULT_FN}")
    set_page_meta_image_tags(image_url,
                             META_IMAGE_DEFAULT_TYPE,
                             width:  META_IMAGE_DEFAULT_WIDTH,
                             height: META_IMAGE_DEFAULT_HEIGHT)
  end


  # Given the image filename for an image (ex: 'Sveriges_hundforetagare_banner_sajt.jpg')
  # create the right meta tags for that image:
  #   - image_src
  #   - og:image (including the type, height, and width)
  #
  # I use keyword params for width and height because I personally have to
  # look up param order whenever there's both a width and height to see what
  # order is wanted. Keywords solve that.
  #
  # TODO: allow multiple images to be set for og.image
  #
  # @param image_url [String] - the complete url to the image.
  # @param [String] image_type -  the string representing the image type, to tell OpenGraph the type (e.g. 'jpeg', 'png', etc.)
  # @param [Integer] width - width of the image if known; will be used if given
  # @param [Integer] height - height of the image if known; will be used if given
  #
  def set_page_meta_image_tags(image_url, image_type, width: 0, height: 0)

    #image_asset_url = asset_url("assets/#{image_filename}")

    set_meta_tags image_src: image_url,
                  og:        {
                      image: {
                          _:      image_url,
                          type:   "image/#{image_type}",
                          width:  width,
                          height: height
                      }
                  }
  end


  # This sets the meta tags for a page with 'no-follow' and 'no-index' robots tags.
  # (The meta-tags gem doesn't have a 'none' method, which covers both.)
  # This should be used for pages that we do not want indexed or crawled (followed)
  # by search engine robots.
  #
  # After this is called, a child Controller or the view can add to it as needed.
  #
  def set_page_meta_robots_none
    set_meta_tags nofollow: true,
                  noindex:  true
  end


  # ============================================================================


  private


  # Create the string with the keywords.
  # Use the default meta keywords if there is no locale entry .keywords
  # and append the BusinessCategories to the end
  #
  # @return [String] - a string of comman-separated keywords
  def create_keywords

    keywords      = t(LOCALE_KEYWORDS_KEY, default: META_KEYWORDS_DEFAULT)
    business_cats = BusinessCategory.pluck(:name).uniq

    cats_str = business_cats.empty? ? '' : ', ' + business_cats.join(', ')
    keywords + cats_str
  end


  # get the IETF code for our current locale.  default is 'sv_SE'
  def meta_og_locale
    LOCALES_TO_IETF.fetch(I18n.locale, 'sv_SE')
  end


  # appends the site title to the page_title
  def meta_full_title(page_title)
   "#{page_title} | #{META_SITE_NAME}"
  end


  def meta_default_full_title
    meta_full_title(META_TITLE_DEFAULT)
  end

end
