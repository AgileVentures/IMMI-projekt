module UsersHelper

  def most_recent_login_time user
    user.current_sign_in_at.blank? ? user.last_sign_in_at : user.current_sign_in_at
  end

  def expire_date_label_and_value user
    expire_date = user.membership_expire_date

    if !expire_date
      return field_or_none("#{t('activerecord.attributes.payment.expire_date')}",
                           "#{t('none')}", label_class: 'standard-label')
    end

    # Show expire date as yellow if within 1 month from today, red if expired
    value_class = expire_date_css_class(expire_date)

    return field_or_none("#{t('activerecord.attributes.payment.expire_date')}",
                         "#{expire_date}",
                         label_class: 'standard-label',
                         value_class: value_class)
  end

  def expire_date_css_class(expire_date)
    today = Date.current
    if today < expire_date << 1
      value_class = 'Yes'  # green
    elsif today >= expire_date
      value_class = 'No'
    else
      value_class = 'Maybe'
    end
    value_class
  end

  def pay_member_fee_link(user)
    # Returns link styled as a button
    return nil unless user.allow_pay_member_fee?

    link_to("#{t('menus.nav.members.pay_membership')}",
            payments_path(user_id: user.id,
                          type: Payment::PAYMENT_TYPE_MEMBER),
            { method: :post, class: 'btn btn-primary btn-xs' })
  end

  def payment_notes_label_and_value(user)
    notes = user.payment_notes
    if !notes || notes.empty?
      return field_or_none("#{t('activerecord.attributes.payment.notes')}",
                           "#{t('none')}", label_class: 'standard-label')
    end
    return field_or_none("#{t('activerecord.attributes.payment.notes')}",
                         notes, label_class: 'standard-label')
  end

end
