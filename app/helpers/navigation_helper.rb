#--------------------------
#
# @class NavigationHelper
#
# @desc Responsibility: Helpers for navigation (menus, etc.)
#           One place to define URLS, etc. that are used frequently

# - Methods that end with _url will return an URL that can be used.  It will have the
# "http://|https://" (or whatever) at the start and will be valid.
#
# - Methods that end with _part  return just the [String] part specific to that url
# You need to concat them together with something else (like :https and :shf_main_site_hom_part)
# to create a full URL
#
# The names of the methods are long. That makes them very clear, but
# there's likely to be some good ideas to shorten them a bit.
#
# Additional URLS and parts can be added as is helpful.
# This is just a start.
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   18/12/21
#
# @file navigation_helper.rb
#
module NavigationHelper

  SLASH = '/'


  def https_shf_main_site_home_url
    make_https_url([shf_main_site_home_url_part])
  end


  def https_shf_main_site_association_url
    make_https_url([shf_main_site_home_url_part, association_url_part])
  end


  def https_shf_main_site_brochure_url
    make_https_url([shf_main_site_home_url_part, brochure_url_part])
  end


  def https_shf_main_site_board_url
    make_https_url([shf_main_site_home_url_part, board_url_part])
  end


  def https_shf_main_site_board_our_policy_url
    make_https_url([shf_main_site_home_url_part, board_our_policy_url_part])
  end


  def https_shf_main_site_board_statues_url
    make_https_url([shf_main_site_home_url_part, board_statues_url_part])
  end


  def https_shf_main_site_history_url
    make_https_url([shf_main_site_home_url_part, history_url_part])
  end


  def https_shf_main_site_contact_url
    make_https_url([shf_main_site_home_url_part, contact_url_part])
  end

  def https_shf_main_site_plug_url
    make_https_url([shf_main_site_home_url_part, plug_url_part])
  end

  # ----------------
  # For Dog Owners
  #
  def https_shf_main_site_for_dog_owners_url
    make_https_url([shf_main_site_home_url_part, for_dog_owners_url_part])
  end

  def https_shf_main_site_dog_owners_about_us_url
    make_https_url([shf_main_site_home_url_part, about_us_for_dog_owners_url_part])
  end


  def https_shf_main_site_dog_owners_h_brand_url
    # 'https://sverigeshundforetagare.se/agare/h-markt-av-sveriges-hundforetagare/'
    make_https_url([shf_main_site_home_url_part, h_brand_dog_owners_url_part])
  end


  def https_shf_main_site_dog_owners_knowledgebank_url
    make_https_url([shf_main_site_home_url_part, knowledgebank_dog_owners_url_part])
  end


  def https_shf_main_site_dog_owners_contact_url
    make_https_url([shf_main_site_home_url_part, dog_owners_are_you_interested_contact_url_part])
  end


  def https_shf_main_site_dog_owners_become_support_member_url
    make_https_url([shf_main_site_home_url_part, become_support_member_dog_owners_url_part])
  end


  def https_shf_main_site_dog_owner_being_dog_owner_url
    make_https_url([shf_main_site_home_url_part, being_a_dog_owner_dog_owners_url_part])
  end


  # ----------------
  # For Companies
  #
  def https_shf_main_site_for_companies_url
    make_https_url([shf_main_site_home_url_part, for_companies_url_part])
  end


  def https_shf_main_site_about_us_for_companies_url
    make_https_url([shf_main_site_home_url_part, about_us_for_companies_url_part])
  end


  def https_shf_main_site_companies_knowledgebank_url
    make_https_url([shf_main_site_home_url_part, knowledgebank_companies_url_part])
  end


  def https_shf_main_site_companies_sign_up_url
    make_https_url([shf_main_site_home_url_part, sign_up_for_companies_url_part])
  end


  def https_shf_main_site_companies_become_h_licensed_url
    make_https_url([shf_main_site_home_url_part, become_h_licensed_companies_url_part])
  end


  def https_shf_main_site_companies_member_criteria_url
    make_https_url([shf_main_site_home_url_part, member_criteria_companies_url_part])
  end


  def https_shf_main_site_companies_member_benefits_url
    make_https_url([shf_main_site_home_url_part, member_benefits_companies_url_part])
  end


  def https_shf_main_site_companies_gdpr_url
    make_https_url([shf_main_site_home_url_part, gdpr_companies_url_part])
  end


  def https_shf_main_site_companies_quality_control_companies_url
    make_https_url([shf_main_site_home_url_part, quality_control_companies_url_part])
  end

  def https_shf_main_site_companies_knowledgebank_blogs_url
    make_https_url([shf_main_site_home_url_part, knowledgebank_companies_blogs_url_part])
  end

  def https_shf_main_site_companies_knowledgebank_books_url
    make_https_url([shf_main_site_home_url_part, knowledgebank_companies_books_url_part])
  end

  def https_shf_main_site_companies_knowledgebank_research_url
    make_https_url([shf_main_site_home_url_part, knowledgebank_companies_research_url_part])
  end

  def https_shf_main_site_companies_knowledgebank_podcasts_url
    make_https_url([shf_main_site_home_url_part, knowledgebank_companies_podcasts_url_part])
  end

  def https_shf_main_site_companies_knowledgebank_popsci_url
    make_https_url([shf_main_site_home_url_part, knowledgebank_companies_popsci_url_part])
  end

  def https_shf_main_site_companies_knowledgebank_videos_url
    make_https_url([shf_main_site_home_url_part, knowledgebank_companies_videos_url_part])
  end


  # I have this ending with 2 slashes because if someone called this by itself,
  # they would expect _both_ slashes
  #
  def https
    'https://'
  end


  # -----------------------------------------------
  # Parts


  def shf_main_site_home_url_part
    'sverigeshundforetagare.se'
  end


  def brochure_url_part
    'broschyr/'
  end


  def association_url_part
    'foretag/om-sveriges-hundforetagare/styrelse/'
  end


  def board_url_part
    'foretag/om-sveriges-hundforetagare/styrelse/'
  end


  def board_our_policy_url_part
    'foretag/bli-medlem/policyn/'
  end


  def board_statues_url_part
    'stadgar/'
  end


  def history_url_part
    'historik/'
  end


  def contact_url_part
    'kontakt'
  end


  def plug_url_part
    contact_url_part
  end

  #------------------
  # for Dog Owners
  #

  def for_dog_owners_url_part
    'agare/'
  end

  def about_us_for_dog_owners_url_part
    'agare/om-sveriges-hundforetagare/'
  end


  def h_brand_dog_owners_url_part
    'agare/h-markt-av-sveriges-hundforetagare/'
  end


  def knowledgebank_dog_owners_url_part
    'category/kunskapsbank-hundagare/'
  end


  def dog_owners_are_you_interested_contact_url_part
    'agare/ar-du-inte-nojd/'
  end


  def become_support_member_dog_owners_url_part
    'agare/bli-stodmedlem/'
  end


  def being_a_dog_owner_dog_owners_url_part
    'agare/att-vara-hundagare/'
  end


  #------------------
  # for Companies
  #

  def for_companies_url_part
    'foretag/'
  end

  def about_us_for_companies_url_part
    'foretag/om-sveriges-hundforetagare/'
  end


  def sign_up_for_companies_url_part
    'foretag/bli-medlem/'
  end


  def become_h_licensed_companies_url_part
    'foretag/bli-h-markt/'
  end


  def member_criteria_companies_url_part
    'medlemskriterier/'
  end


  def member_benefits_companies_url_part
    'foretag/detta-far-du-som-medlem/'
  end


  def gdpr_companies_url_part
    'foretag/gdpr/'
  end


  def quality_control_companies_url_part
    'foretag/kvalitetskontroll/'
  end


  def knowledgebank_companies_url_part
    'kunskapsbank-foretagare/'
  end


  def knowledgebank_companies_blogs_url_part
    'category/bloggar/'
  end

  def knowledgebank_companies_books_url_part
    'category/bocker/'
  end
  def knowledgebank_companies_research_url_part
    'category/forskning/'
  end

  def knowledgebank_companies_podcasts_url_part
    'category/pod/'
  end

  def knowledgebank_companies_popsci_url_part
    'category/popularvetenskap/'
  end

  def knowledgebank_companies_videos_url_part
    'category/video/'
  end


  # -----------------------------------------------------------------------


  private


  # @return [String] - a valid URL that ends with a SLASH
  def make_https_url(list_of_parts)
    add_trailing_slash (https + list_of_parts.join(SLASH))
  end


  def add_trailing_slash(url)
    url.end_with?(SLASH) ? url : (url + SLASH)
  end
end
