#!/usr/bin/ruby


#--------------------------
#
# @module PageMetaOgTagsSetter
#
# @desc Responsibility: Sets meta info for OpenGraph info for a page
#
# This encapsulates all of the logic and info needed to set OpenGraph (og) tags.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-03-04
#
# @file page_meta_og_tags_setter.rb
#
#--------------------------


module PageMetaOgTagsSetter


  # Rails I18n usually uses a 2 letter language codes for the locale.
  # But Facebook's OpenGraph ('og') requires a language code and country (region)
  # code per the IETF language standard  https://en.wikipedia.org/wiki/IETF_language_tag
  # This is a simple mapping to the locales we're using.  If we start supporting
  # more languages and/or regions, this can be made more complex.
  LOCALES_TO_IETF = { sv: 'sv_SE',
                      en: 'en_US'
  }




  def set_og_meta_tags(site_name: SiteMetaInfoDefaults.site_name,
                       title: helpers.full_page_title,
                       description: SiteMetaInfoDefaults.description,
                       type: SiteMetaInfoDefaults.og_type,
                       base_url: self.request.base_url,
                       fullpath:  '/')

    set_meta_tags og: {
        site_name:   site_name,
        title:       title,
        description: description,
        url:         base_url + fullpath,
        type:        type,
        locale:      meta_og_locale
    }
  end



  # ============================================================================


  private


  # get the IETF code for our current locale.  default is 'sv_SE'
  def meta_og_locale
    LOCALES_TO_IETF.fetch(I18n.locale, 'sv_SE')
  end


end
