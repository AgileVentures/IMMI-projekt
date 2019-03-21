module MemberMailerHelper

  # The link and text to a member's account page (to be used in emails).
  # Uses _blank so that it will open in a new browser window.
  #
  def member_account_link(member, capitalize: false)
    link_text = t('menus.nav.users.your_account')
    link_text = capitalize ? link_text.capitalize : link_text.downcase
    link_to(link_text, user_url(member), target: '_blank', rel: 'nofollow')
  end

end
