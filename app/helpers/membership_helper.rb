module MembershipHelper

  def membership_last_day_and_value(membership, i18n_scope = 'users',
                              label_class: default_field_label_css_class,
                              value_class: default_field_value_css_class)

    expire_date = membership&.last_day
    t_scope = i18n_scope  # entity.is_a?(User) ? 'users' : 'companies' # TODO - should use polymorphism to handle this

    expire_after_tooltip_title = t("#{t_scope}.show.term_expire_date_tooltip")
    expire_label = t("#{t_scope}.show.membership_term_last_day")

    if expire_date
      value_classes = [value_class, default_field_value_css_class]
      value_classes << 'maybe' if membership.user.membership_expires_soon?(membership)
      tag.div do
        concat tag.span "#{expire_label}: ", class: label_class
        concat tag.span "#{expire_date}", class: value_classes
        concat ' '
        concat fas_tooltip(expire_after_tooltip_title)
      end
    else
      field_or_none(expire_label, t('none_t'), label_class: label_class, value_class: value_class)
    end
  end


  # @return [String] - HTML to display a label and value for membership notes
  def membership_notes_label_and_value(notes = '')
    display_text = notes.blank? ? t('none_plur') : notes
    field_or_none("#{t('activerecord.attributes.membership.notes')}",
                  display_text, tag: :div)
  end
end
