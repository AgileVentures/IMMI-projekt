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
            { method: :post, class: 'btn btn-primary btn-xs' })
  end

end
