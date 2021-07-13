class EmailValidator < ActiveModel::EachValidator
  # OLD_EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  # OLD_EMAIL_REGEXP is generally ok, but does not allow domain names without a '.' -- which _are_ technically correct, even if unusual.
  #   That regexp also did not enforce other restrictions that it should have.
  # Note that the URI::MailTo::EMAIL_REGEXP is based on RFC 2368 and slightly more restrictive than RFC 5322.
  # mailto: a URI and so does not allow characters that an email address does.

  def validate_each(object, attribute, value)
    if value.to_s !~ URI::MailTo::EMAIL_REGEXP
      object.errors[attribute] << "#{I18n.t('errors.messages.invalid')}: #{value}"
    end
  end
end
