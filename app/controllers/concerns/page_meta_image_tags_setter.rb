#!/usr/bin/ruby


require 'mini_magick'

require 'site_meta_info_defaults'


#--------------------------
#
# @module PageMetaImageTagsSetter
#
# @desc Responsibility: Set meta information for images (for a page).
# If no specific value is provided for a tag, information is looked up in
# locale files. Falls back to site defaults if an entry is not found in
# the locale files.
#
# This encapsulates all of the logic and info needed to set image tags.
# It's complicated enough to justify pulling out into its own module.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-03-04
#
# @file page_meta_image_tags_setter.rb
#
#--------------------------


module PageMetaImageTagsSetter

  LOCALE_IMAGE_KEY = '.meta.image_src'


  # TODO: handle more than 1 image for a page. get possible comma sep. list from locale
  # Set meta tags for the page images.
  # If no filename is provided or if it doesn't exit,
  #   use the filename given in the locale file or the default.
  #
  def set_page_meta_images(full_image_filepath = nil, full_image_url = nil)

    if full_image_filepath && File.exist?(full_image_filepath)
      # make a temp. copy of the file just to be safe
      image = MiniMagick::Image.new(full_image_filepath)
      set_page_meta_image_tags(full_image_url,
                               image.type.downcase,
                               width:  image.width,
                               height: image.height)

    else
      fallback_to_locale_or_default_image
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
    image_fn            = t(LOCALE_IMAGE_KEY)
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
    image_url = asset_url("assets/#{SiteMetaInfoDefaults.image_filename}")

    set_page_meta_image_tags(image_url,
                             SiteMetaInfoDefaults.image_type,
                             width:  SiteMetaInfoDefaults.image_width,
                             height: SiteMetaInfoDefaults.image_height)
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

end

