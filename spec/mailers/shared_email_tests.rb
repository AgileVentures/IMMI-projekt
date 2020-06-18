require 'email_spec/rspec'

# Attributes and Email components common to emails sent to *members*
#   This includes text in the body that has text about 'email us with questions...'
# Assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'a successfully created email to a member' do |subject, recipient, from_email, replyto_email, greeting|
  it "email us with questions reply to email address is ENV['SHF_REPLY_TO_EMAIL']" do
    expect(email_created).to have_body_text(ENV['SHF_REPLY_TO_EMAIL'])
  end

  it_behaves_like 'a successfully created email', subject, recipient, from_email, replyto_email, greeting
end

# Assumes that 'mail_address' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'from address is correct' do
  it "is a Mail::Field" do
    expect(mail_address).to be_a Mail::Field
  end

  it "has both display name (ENV['SHF_EMAIL_DISPLAY_NAME']) and email address ENV['SHF_FROM_EMAIL']" do
    expect(mail_address.to_s).to match(/"#{ENV['SHF_EMAIL_DISPLAY_NAME']}" <#{ENV['SHF_FROM_EMAIL']}>/)
  end
end

# Assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'reply-to address is correct' do
  let(:mail_address) { email_created.header['reply-to'] }

  it 'only 1 reply_to address' do
    actual_reply_to =  email_created.reply_to
    expect(actual_reply_to.size).to eq 1
  end

  it "is a Mail::Field" do
    expect(mail_address).to be_a Mail::Field
  end

  it "has both display name (ENV['SHF_EMAIL_DISPLAY_NAME']) and email address ENV['SHF_FROM_EMAIL']" do
    expect(mail_address.to_s).to match(/"#{ENV['SHF_EMAIL_DISPLAY_NAME']}" <#{ENV['SHF_REPLY_TO_EMAIL']}>/)
  end
end

# Attributes and Email components common to _all_ emails sent, whether to admins, members, applicants, etc. .
# Assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
#   Does *not* include any text about 'email us with questions...'
RSpec.shared_examples 'a successfully created email' do |subject, recipient, greeting_name, signoff, signature|

  DEFAULT_SIGNOFF =   I18n.t('mailers.application_mailer.signoff') unless
                        defined?(DEFAULT_SIGNOFF)
  DEFAULT_SIGNATURE = I18n.t('mailers.application_mailer.signature') unless
                        defined?(DEFAULT_SIGNATURE)

  it 'subject is correct' do
    expect(email_created).to have_subject(subject)
  end

  it 'recipient is correct' do
    expect(email_created).to deliver_to(recipient)
  end

  it 'greeting is correct' do
    expect(email_created).to have_body_text( I18n.t('mailers.application_mailer.greeting', greeting_name: greeting_name))
  end

  signoff ||= DEFAULT_SIGNOFF
  it "signoff is #{signoff}" do
    expect(email_created).to have_body_text(signoff)
  end

  signature ||= DEFAULT_SIGNATURE
  it "signature is #{signature}" do
    expect(email_created).to have_body_text(signature)
  end

  describe 'footer is correct' do
    it "has: this email sent to #{recipient}... note" do
      email_created.parts.each do |mail_part|
        expect(mail_part).to have_body_text(I18n.t('mailers.application_mailer.footer.text.email_sent_to', email_sent_to: @recipient_email).html_safe)
      end
    end

    it 'text part has correct link to SHF site home page' do
      unless email_created.text_part.nil?
        expect(email_created.text_part).to have_body_text(I18n.t('shf_home_url'))
      end
    end

    it 'html part has correct link to SHF site home page' do
      unless email_created.html_part.nil?
        expect(email_created.html_part.body.encoded).to have_link(I18n.t('shf_home_url'), href: root_url)
      end
    end

    it 'text part has correct link to SHF Facebook page' do
      unless email_created.text_part.nil?
        expect(email_created.text_part).to have_body_text(I18n.t('shf_facebook_url'))
      end
    end

    it 'html part has correct link to SHF Facebook page' do
      unless email_created.html_part.nil?
        expect(email_created.html_part.body.encoded).to have_link(I18n.t('shf_facebook_url'), href: I18n.t('shf_facebook_url'))
      end
    end

    it 'text part has correct link to SHF Instagram page' do
      unless email_created.text_part.nil?
        expect(email_created.text_part).to have_body_text(I18n.t('shf_instagram_url'))
      end
    end

    it 'html part has correct link to SHF Instagram page' do
      unless email_created.html_part.nil?
        expect(email_created.html_part.body.encoded).to have_link(I18n.t('shf_instagram_url'), href: I18n.t('shf_instagram_url'))
      end
    end
  end
end

# Assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'it shows the user the login page and their login email' do
  it 'login page link and their login email are in the email' do
    expect(email_created).to have_body_text(I18n.t('mailers.login_here'))
    expect(email_created).to have_body_text(I18n.t('mailers.your_login_email_is'))
  end

  it 'link to the login page with _blank so it opens in a new window' do
    #<a target=\"_blank\" href=\"http://localhost:3000/users/sign_in\">
    expect(email_created).to have_body_text("<a target=\"_blank\" href=\"#{new_user_session_url}\">")
  end
end

# Assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'it shows how to login and the page to pay the H-markt fee' do
  it_behaves_like 'it shows the user the login page and their login email'

  it 'has a title for the steps' do
    expect(email_created).to have_body_text(I18n.t('mailers.how_to_pay_hmarkt'))
  end

  it 'has a line explaining to go to company page' do
    expect(email_created).to have_body_text(I18n.t('mailers.pay_hmarkt_step'))
  end

  it 'has a link to the company page' do
    expect(email_created).to have_body_text(I18n.t('mailers.here_is_co_page'))
    expect(email_created).to have_body_text("<a target=\"_blank\" href=\"#{company_url(company)}\">#{company.name}</a>")
  end

  it 'has a line explaining that they can see the H-markt expiration on the company page' do
    expect(email_created).to have_body_text(I18n.t('mailers.h_brand_exp_shown'))
  end
end

# Assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'it shows how to login and the page to pay the membership fee' do
  it_behaves_like 'it shows the user the login page and their login email'

  it 'has a title for the steps' do
    expect(email_created).to have_body_text(I18n.t('mailers.how_to_pay_membership'))
  end

  it 'has a line explaining to go to the account page' do
    expect(email_created).to have_body_text(I18n.t('mailers.pay_membership_step'))
  end

  it 'has a link to the account page' do
    expect(email_created).to have_body_text(I18n.t('mailers.here_is_acct_page'))
    expect(email_created).to have_body_text("<a target=\"_blank\" href=\"#{user_url(user)}\">#{user_url(user)}</a>")
  end
end

# Assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'it shows how to login and the page to upload files' do
  it_behaves_like 'it shows the user the login page and their login email'

  it 'says there will be a button to the app where you can upload files' do
    expect(email_created).to have_body_text(I18n.t('mailers.shf_application_mailer.will_see_app_button'))
  end
end
