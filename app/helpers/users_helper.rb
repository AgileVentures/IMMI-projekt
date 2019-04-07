module UsersHelper

  def most_recent_login_time user
    user.current_sign_in_at.blank? ? user.last_sign_in_at : user.current_sign_in_at
  end

  def pay_member_fee_link(user)
    # Returns link styled as a button
    return nil unless user.allow_pay_member_fee?

    link_to("#{t('menus.nav.members.pay_membership')}",
            payments_path(user_id: user.id,
                          type: Payment::PAYMENT_TYPE_MEMBER),
            { method: :post, class: 'btn btn-secondary btn-sm' })
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

  def short_proof_of_membership_url(user)
    url = proof_of_membership_url(user.id)
    user.get_short_proof_of_membership_url(url)
  end
end
