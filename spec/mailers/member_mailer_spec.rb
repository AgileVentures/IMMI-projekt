require 'rails_helper'
require 'email_spec/rspec'

require File.join(__dir__, 'shared_email_tests')

require_relative './previews/member_mailer_preview'

# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct
#
RSpec.describe MemberMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:test_user) { create(:user, email: 'user@example.com') }


  describe '#membership_granted' do

    MEM_GRANTED_SCOPE = 'mailers.member_mailer.membership_granted'


    let(:accepted_app) { create(:shf_application, :accepted, user: test_user) }
    let(:email_sent) { MemberMailer.membership_granted(accepted_app.user) }


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: MEM_GRANTED_SCOPE),
                    'user@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'repeats the welcome from the subject line' do
      expect(email_sent).to have_body_text(I18n.t('message_text.welcome', scope: MEM_GRANTED_SCOPE))
    end

    it 'says you are now an active member' do
      expect(email_sent).to have_body_text(I18n.t('message_text.youre_active', scope: MEM_GRANTED_SCOPE))
    end

    it 'gives you the Facebook group URL' do
      expect(email_sent).to have_body_text(I18n.t('message_text.access_fb_group', scope: MEM_GRANTED_SCOPE))
    end

    it 'tell you about the Member Pages' do
      expect(email_sent).to have_body_text(I18n.t('message_text.and_member_pages', scope: MEM_GRANTED_SCOPE))
    end


    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  describe '#membership_expiration_reminder' do

    MEMBERSHIP_EXP_SCOPE = 'mailers.member_mailer.membership_will_expire'

    let(:member) { create(:member_with_membership_app, user: test_user) }
    let(:member) do
      test_user.member = true
      test_user.payments << create(:payment, :successful,
                                   expire_date: Time.zone.today + 1.month)
      test_user.save!
      test_user
    end

    let(:email_sent) { MemberMailer.membership_expiration_reminder(member) }

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: MEMBERSHIP_EXP_SCOPE),
                    'user@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'tells you when your membership expires' do
      expect(email_sent).to have_body_text(I18n.t('message_text.expire_alert_html',
                                                  scope:       MEMBERSHIP_EXP_SCOPE,
                                                  expire_date: member.membership_expire_date))
    end

    it 'tells how to extend membership' do
      expect(email_sent).to have_body_text(I18n.t('message_text.extend_membership',
                                                  scope: MEMBERSHIP_EXP_SCOPE))
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  describe '#h_branding_fee_past_due' do

    HBRANDING_PAST_DUE_SCOPE = 'mailers.member_mailer.h_branding_fee_past_due'

    let(:jan1) { Date.new(2019, 1, 1) }

    let(:company2) { create(:company) }

    let(:member1_exp_jan1) do
      app = create(:shf_application, :accepted, company_number: company2.company_number)
      m   = app.user
      m.email = 'only_member@example.com'
      m.payments << create(:payment, :successful,
                           expire_date: jan1)
      m.save!
      m
    end

    let(:email_sent) do
      # create the company and members
      member1_exp_jan1
      MemberMailer.h_branding_fee_past_due(company2, member1_exp_jan1)
    end

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: HBRANDING_PAST_DUE_SCOPE),
                    'only_member@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end


    it 'tells you the H-branding fee is unpaid' do
      expect(email_sent).to have_body_text(I18n.t('message_text.fee_is_unpaid',
                                                  scope: HBRANDING_PAST_DUE_SCOPE))
    end

    it 'tells how to pay the H-branding fee' do
      expect(email_sent).to have_body_text(I18n.t('message_text.how_to_pay_fee',
                                                  scope: HBRANDING_PAST_DUE_SCOPE))
    end

    it 'provides a link to the company and a reminder that you might have to log in' do
      expect(email_sent).to have_body_text(I18n.t('message_text.company_link_login_msg',
                                                  scope: HBRANDING_PAST_DUE_SCOPE,
                                           company_link: "<a href=\"#{company_url(company2)}\">#{company2.name}</a>") )
    end


    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end #describe '#h_branding_fee_past_due


  describe '#membership_lapsed' do

    MEMBERSHIP_LAPSED_SCOPE = 'mailers.member_mailer.membership_lapsed'

    let(:member) { create(:member_with_membership_app, user: test_user) }
    let(:member) do
      test_user.member = true
      test_user.payments << create(:payment, :successful,
                                   expire_date: Time.zone.today - 1.month)
      test_user.save!
      test_user
    end

    let(:email_sent) { MemberMailer.membership_lapsed(member) }

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: MEMBERSHIP_LAPSED_SCOPE),
                    'user@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'tells you when your membership expired' do
      expect(email_sent).to have_body_text(I18n.t('message_text.expire_alert_html',
                                                  scope:       MEMBERSHIP_LAPSED_SCOPE,
                                                  expire_date: member.membership_expire_date))
    end

    it 'tells how to renew membership' do
      expect(email_sent).to have_body_text(I18n.t('message_text.renew_membership',
                                                  scope: MEMBERSHIP_LAPSED_SCOPE))
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  describe '#company_info_incomplete' do

    CO_INFO_INCOMPLETE_SCOPE = 'mailers.member_mailer.co_info_incomplete'

    let(:jan1) { Date.new(2019, 1, 1) }

    let(:co_no_name_no_region) do
      co = create(:company)
      co.name = ''
      co.addresses.first.update(region: nil)
      co
    end

    let(:member_noname_noregion) do
      app = create(:shf_application, :accepted, company_number: co_no_name_no_region.company_number)
      m   = app.user
      m.email = 'only_member@example.com'
      m.payments << create(:payment, :successful,
                           expire_date: jan1)
      m.save!
      m
    end

    let(:display_for_blank_name) do
      I18n.t('mailers.member_mailer.co_info_incomplete.message_text.company_needs_name', co_number: co_no_name_no_region.company_number)
    end

    let(:email_sent_co_noname_noregion) do
      # create the company and members
      member_noname_noregion
      MemberMailer.company_info_incomplete(co_no_name_no_region, member_noname_noregion)
    end

    let(:complete_co) { create(:company) }

    let(:member_complete_co) do
      app = create(:shf_application, :accepted, company_number: complete_co.company_number)
      m   = app.user
      m.email = 'member_complete_co@example.com'
      m.payments << create(:payment, :successful,
                           expire_date: jan1)
      m.save!
      m
    end

    let(:email_sent_complete_co) do
      # create the company and members
      member_complete_co
      MemberMailer.company_info_incomplete(complete_co, member_complete_co)
    end


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: CO_INFO_INCOMPLETE_SCOPE),
                    'only_member@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent_co_noname_noregion }
    end


    it 'tells you info needs to be completed so visitors can see the company' do
      expect(email_sent_co_noname_noregion).to have_body_text(I18n.t('message_text.complete_the_info',
                                                  scope: CO_INFO_INCOMPLETE_SCOPE,
                                                  co_identifier: display_for_blank_name))
    end


    describe 'shows a list of information that is missing' do

      it 'lists the company name if it is blank' do
        expect(email_sent_co_noname_noregion).to have_body_text(I18n.t('message_text.co_name_missing',
                                                    scope: CO_INFO_INCOMPLETE_SCOPE))
      end

      it 'does not list the company name if it is not blank' do

        expect(email_sent_complete_co).not_to have_body_text(I18n.t('message_text.co_name_missing',
                                                    scope: CO_INFO_INCOMPLETE_SCOPE))
      end

      it 'lists the region if it is nil' do
        expect(email_sent_co_noname_noregion).to have_body_text(I18n.t('message_text.co_region_missing',
                                                    scope: CO_INFO_INCOMPLETE_SCOPE))
      end

      it 'does not list the region if it is not nil' do
        expect(email_sent_complete_co).not_to have_body_text(I18n.t('message_text.co_region_missing',
                                                    scope: CO_INFO_INCOMPLETE_SCOPE))

      end
    end


    it 'provides a link to the company and a reminder that you might have to log in' do
      expect(email_sent_co_noname_noregion).to have_body_text(I18n.t('message_text.company_link_login_msg',
                                                  scope: CO_INFO_INCOMPLETE_SCOPE,
                                                  company_link: "<a href=\"#{company_url(co_no_name_no_region)}\">#{co_no_name_no_region.name}</a>") )
    end

    it_behaves_like 'it provides a link to the login page' do
      let(:email_created) { email_sent_co_noname_noregion }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent_co_noname_noregion.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent_co_noname_noregion }
    end
  end

  describe '#app_no_uploaded_files' do

    NO_UPLOADED_FILES_SCOPE = 'mailers.member_mailer.app_no_uploaded_files'

    let(:applicant) { create(:user_with_membership_app, email: 'user_new@example.com') }

    let(:email_sent) { MemberMailer.app_no_uploaded_files(applicant) }

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: NO_UPLOADED_FILES_SCOPE),
                    'user_new@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  describe '#hbranding_fee_will_expire' do

    HBRAND_FEE_WILLEXPIRE_SCOPE = 'mailers.member_mailer.h_branding_fee_will_expire'

    let(:jan1_2020) { Date.new(2020, 1, 1) }

    let(:company3) { create(:company) }

    let(:member1_exp_jan1) do
      app = create(:shf_application, :accepted, company_number: company3.company_number)
      m   = app.user
      m.email = 'only_member@example.com'
      m.payments << create(:payment, :successful,
                           expire_date: jan1_2020)
      m.save!
      m
    end

    let(:email_sent) do
      # create the company and members
      member1_exp_jan1
      MemberMailer.h_branding_fee_will_expire(company3, member1_exp_jan1)
    end


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: HBRAND_FEE_WILLEXPIRE_SCOPE),
                    'only_member@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'tells you when the HBranding license will expire' do
      expect(email_sent).to have_body_text(I18n.t('message_text.expire_alert_html',
                                                  scope:       HBRAND_FEE_WILLEXPIRE_SCOPE,
                                                  expire_date: company3.branding_expire_date))
    end

    it 'tells how to pay the fee' do
      expect(email_sent).to have_body_text(I18n.t('message_text.how_to_pay_fee',
                                                  scope: HBRAND_FEE_WILLEXPIRE_SCOPE))
    end

    it 'has a link to the company' do
      expect(email_sent).to have_body_text(/<a(.*)>#{company3.name}<\/a>/)
    end

    it 'says you may need to log in' do
      expect(email_sent).to have_body_text(I18n.t('message_text.company_link_login_msg',
                                                  scope: HBRAND_FEE_WILLEXPIRE_SCOPE))
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  it 'has a previewer' do
    expect(MemberMailerPreview).to be
  end

end
