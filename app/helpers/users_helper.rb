module UsersHelper

  def most_recent_login_time user
    user.current_sign_in_at.blank? ? user.last_sign_in_at : user.current_sign_in_at
  end


  def paperclip_path_str(attached_file, image_type, render_to)
    # Produces path for attached_file, for use in image_tag method.
    #  attached_file: Model attribute managed via paperclip
    #  image_type: defined style name (symbol) used in `has_attached_file`.
    #  render_to: if == :html, the template from which this is called will be
    #             rendered as HTML.  If == :jpg, will be rendered as image
    # Rendering as image is peformed via IMGKit gem, which requires that
    #  image tag src be a full path to the asset.

    return attached_file.url(image_type) if render_to == :html

    return attached_file.path(image_type).to_s if attached_file.path

    # If we get here it means that we need a full path, but that the
    # attached file has not been created, and we only have the default
    # imaged specified in `has_attached_file` (via `default_url` option).
    # This will provide a relative path only (via `url` message), and so we
    # must prepend the rest of the path.
    return Rails.root.join('app', 'assets', 'images',
                           attached_file.url(image_type)).to_s
  end

  def user_has_open_application(user)
    return nil unless user.shf_application

    user.shf_application.state.to_sym.in?([:accepted, :rejected]) ? nil : t('yes')
  end

  def proof_of_membership_jpg_url(user)
    proof_of_membership_url(user) + '.jpg'
  end


  def short_proof_of_membership_url(user)
    url = proof_of_membership_jpg_url(user.id)
    user.get_short_proof_of_membership_url(url)
  end


  I18N_USERS_SHOW = 'users.show_info_for_admin_only'.freeze

  # creates a human-readable string that says if the membership packet
  # was sent and on what date.
  # @return [String] - a string in the form
  #   <'membership packet' translation> <sent | not sent>  <date if it was sent>
  def membership_packet_str(user)

    mem_packet    = t('member_packet', scope: I18N_USERS_SHOW).capitalize
    packet_status = membership_packet_status_str(user.membership_packet_sent?)
    add_on_date   = ''

    add_on_date << ' ' + user.date_membership_packet_sent.to_date.to_s if user.membership_packet_sent?

    "#{mem_packet} #{packet_status}#{add_on_date}"
  end


  def membership_packet_status_str(was_sent)
    t(was_sent ? 'sent' : 'not_sent', scope: I18N_USERS_SHOW)
  end


  # Checkbox for whether or not a membership packet has been sent to a user.
  # Set the checkbox HTML id to so that
  #
  # @param user [User]- the user that may or may not have a membership packet sent yet
  # @return [String] - html_safe string that is a checkbox with a label for it
  def member_packet_sent_checkbox(user)

    (check_box_tag 'date_membership_packet_sent',
                   user.membership_packet_sent?,
                   user.membership_packet_sent?,
                  class:    'checkbox.membership-packet',
                   data: { remote: true,
                           method: :post,
                           url: user_toggle_membership_package_sent_path(user) }).html_safe
  end

end
