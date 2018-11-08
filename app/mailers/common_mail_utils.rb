# Common methods used by mailers. These can be included both in classes that
# must inherit from Devise::Mailer or ApplicationMailer (or any other mailer class).
module CommonMailUtils

  private

  def set_mail_info(method_sym, recipient)
    set_greeting_name recipient
    set_recipient_email recipient

    @action_name = method_sym.to_s
  end


  def set_greeting_name(recipient)

    if recipient.respond_to?(:full_name)
      @greeting_name = "#{recipient.full_name}"
    elsif recipient.respond_to? :email
      @greeting_name = recipient.email
    end

  end


  def set_recipient_email(recipient)
    @recipient_email = recipient.email if recipient.respond_to? :email
  end


end
