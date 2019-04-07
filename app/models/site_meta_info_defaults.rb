#!/usr/bin/ruby


#--------------------------
#
# @class SiteMetaInfoDefaults
#
# @desc Responsibility: Provides the default meta info for the site to any
# class/object that asks for it.
#
# This encapsulates the default data; other classes/objects don't need to know
# where it comes from.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-03-04
#
# @file site_meta_info_defaults.rb
#
#--------------------------


class SiteMetaInfoDefaults

  FB_APPID_KEY = 'SHF_FB_APPID'


  # These are all class methods
  class << self

    def site_name
      I18n.t('SHF_name')
    end


    def title
      I18n.t('meta.default.title')
    end


    def description
      I18n.t('meta.default.description')
    end


    def keywords
      I18n.t('meta.default.keywords')

    end


    def image_filename
      I18n.t('meta.default.image_src')
    end


    def image_type
      'jpeg'
    end


    def image_width
      1245
    end


    def image_height
      620
    end


    def og_type
      'website'
    end


    def facebook_app_id
      ENV.fetch(FB_APPID_KEY, nil).to_i
    end


    def twitter_card_type
      'summary'
    end


    # If the value is blank, use the site default returned by the default_method
    #
    def use_default_if_blank(default_method, value)
      value.blank? ? self.send(default_method) : value
    end
  end

end
