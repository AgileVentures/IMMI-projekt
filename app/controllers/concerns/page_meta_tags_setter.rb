#!/usr/bin/ruby

require 'mini_magick'

require 'site_meta_info_defaults'
require 'page_meta_image_tags_setter'
require 'page_meta_og_tags_setter'


#--------------------------
#
# @module PageMetaInfoSetter
#
# @desc Responsibility: Sets the meta tags for a page. If no specific value is
# provided for a tag, information is looked up in locale files.
# Falls back to site defaults if an entry is not found in the locale files.
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

  include PageMetaImageTagsSetter
  include PageMetaOgTagsSetter



  LOCALE_TITLE_KEY        = '.meta.title'
  LOCALE_DESCRIPTION_KEY  = '.meta.description'
  LOCALE_TYPE_KEY         = '.meta.type'
  LOCALE_KEYWORDS_KEY     = '.meta.keywords'

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

    page_title = t(LOCALE_TITLE_KEY, default: SiteMetaInfoDefaults.title)
    page_desc  = t(LOCALE_DESCRIPTION_KEY, default: SiteMetaInfoDefaults.description)

    set_meta_tags site: SiteMetaInfoDefaults.site_name,
                  title:     page_title,
                  description: page_desc,
                  keywords:    create_keywords

    set_page_meta_images

    set_og_meta_tags(site_name: SiteMetaInfoDefaults.site_name,
                     title: helpers.full_page_title(page_title: page_title),
                     description: page_desc,
                     type: t(LOCALE_TYPE_KEY, default: SiteMetaInfoDefaults.og_type),
                     base_url: base_url,
                     fullpath: request_fullpath)

    set_facebook_meta_tags

    set_twitter_meta_tags(card: t(LOCALE_TWITTER_CARD_KEY, default: SiteMetaInfoDefaults.twitter_card_type))

  end


  def set_facebook_meta_tags(app_id: SiteMetaInfoDefaults.facebook_app_id)
    set_meta_tags fb: {
        app_id: app_id
    }
  end


  def set_twitter_meta_tags(card: 'summary')
    set_meta_tags twitter: {
        card: card
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

    keywords      = t(LOCALE_KEYWORDS_KEY, default: SiteMetaInfoDefaults.keywords)
    business_cats = BusinessCategory.pluck(:name).uniq

    cats_str = business_cats.empty? ? '' : ', ' + business_cats.join(', ')
    keywords + cats_str
  end

end
