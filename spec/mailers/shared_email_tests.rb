require 'email_spec/rspec'

# assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'a successfully created email' do |subject, recipient, greeting|

  it 'subject is correct' do
    expect(email_created).to have_subject(subject)
  end

  it 'recipient is correct' do
    expect(email_created).to deliver_to(recipient)
  end

  it 'greeting is correct' do
    expect(email_created).to have_body_text(greeting)
  end

  it "email us with questions shows membership email address from ENV['SHF_MEMBERSHIP_EMAIL']" do
    expect(email_created).to have_body_text(ENV['SHF_MEMBERSHIP_EMAIL'])
  end


  describe 'footer is correct' do

    it "has: this email sent to #{recipient}... note" do
      email_created.parts.each do |mail_part|
        expect(mail_part).to have_body_text(I18n.t('application_mailer.footer.text.email_sent_to', email_sent_to: @recipient_email).html_safe)
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
