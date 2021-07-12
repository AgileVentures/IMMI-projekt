class EmailValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)

    unless value.to_s =~ URI::MailTo::EMAIL_REGEXP
      object.errors[attribute] << I18n.t('errors.messages.invalid')
    end
  end
end
