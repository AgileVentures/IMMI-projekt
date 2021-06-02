require 'rails_helper'
require 'email_spec/rspec'

require File.join(__dir__, 'shared_email_tests')

require_relative './previews/member_mailer_preview'

# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct

RSpec.describe MemberMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:test_user) { create(:user, email: 'user@example.com') }
  let!(:test_member) { create(:member, email: 'member@example.com') }

  let(:company) do
    co = test_member.companies.first
    # TODO when Company uses Membership, then change this to (from using payments)
    payment = create(:h_branding_fee_payment, user: test_member, company: co,
           expire_date: Date.current + 1.day )
    test_member.payments << payment
    co
  end

  # before(:each) { allow(company).to receive(:branding_expire_date).and_return(Date.current + 1.day) }

  describe 'membership_granted' do

    MEM_GRANTED_SCOPE = 'mailers.member_mailer.membership_granted'

    # let(:accepted_app) { create(:shf_application, :accepted, user: test_user) }
    let(:email_sent) { MemberMailer.membership_granted(test_member) }


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: MEM_GRANTED_SCOPE),
                    'member@example.com',
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

    it_behaves_like 'it shows the user the login page and their login email' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end


  end


  describe 'membership_expiration_reminder' do

    MEMBERSHIP_EXP_SCOPE = 'mailers.member_mailer.membership_will_expire'
    let(:email_sent) { MemberMailer.membership_expiration_reminder(test_member) }

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: MEMBERSHIP_EXP_SCOPE),
                    'member@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'tells you when your membership expires' do
      expect(email_sent).to have_body_text(I18n.t('message_text.expire_alert_html',
                                                  scope:       MEMBERSHIP_EXP_SCOPE,
                                                  expire_date: test_member.membership_expire_date))
    end

    it_behaves_like 'it shows what is required to renew the membership' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'it shows how to login and the page to pay the membership fee' do
      let(:email_created) { email_sent }
      let(:user) { test_member }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end
  end


  describe 'h_branding_fee_past_due' do

    HBRANDING_PAST_DUE_SCOPE = 'mailers.member_mailer.h_branding_fee_past_due'
    let(:email_sent) do
      MemberMailer.h_branding_fee_past_due(company, test_member)
    end

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: HBRANDING_PAST_DUE_SCOPE),
                    'member@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end


    it 'tells you the H-branding fee is unpaid' do
      expect(email_sent).to have_body_text(I18n.t('message_text.fee_is_unpaid',
                                                  scope: HBRANDING_PAST_DUE_SCOPE))
    end

    it_behaves_like 'it shows how to login and the page to pay the H-markt fee' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end
  end


  describe 'membership_lapsed' do

    MEMBERSHIP_LAPSED_SCOPE = 'mailers.member_mailer.membership_lapsed'
    let(:email_sent) { MemberMailer.membership_lapsed(test_member) }

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: MEMBERSHIP_LAPSED_SCOPE),
                    'member@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'tells you when your membership expired' do
      expect(email_sent).to have_body_text(I18n.t('message_text.expire_alert_html',
                                                  scope:       MEMBERSHIP_LAPSED_SCOPE,
                                                  expire_date: test_member.membership_expire_date))
    end

    it_behaves_like 'it shows what is required to renew the membership' do
      let(:email_created) { email_sent }
    end


    it_behaves_like 'it shows how to login and the page to pay the membership fee' do
      let(:email_created) { email_sent }
      let(:user) { test_member }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end
  end


  describe 'company_info_incomplete' do

    CO_INFO_INCOMPLETE_SCOPE = 'mailers.member_mailer.co_info_incomplete'
    let(:co_no_name_no_region) do
      co = test_member.shf_application.companies.first
      co.name = ''
      co.addresses.first.update(region: nil)
      co
    end

    let(:display_for_blank_name) { I18n.t('mailers.member_mailer.co_info_incomplete.message_text.company_needs_name', co_number: co_no_name_no_region.company_number) }
    let(:email_sent_co_noname_noregion) { MemberMailer.company_info_incomplete(co_no_name_no_region, test_member) }

    let(:complete_co) { create(:company) }
    let(:member_complete_co) { create(:member, company_number: complete_co.company_number) }
    let(:email_sent_complete_co) { MemberMailer.company_info_incomplete(complete_co, member_complete_co) }


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: CO_INFO_INCOMPLETE_SCOPE),
                    'member@example.com',
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

    it_behaves_like 'it shows the user the login page and their login email' do
      let(:email_created) { email_sent_co_noname_noregion }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent_co_noname_noregion.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent_co_noname_noregion }
    end
  end


  describe 'app_no_uploaded_files' do

    NO_UPLOADED_FILES_SCOPE = 'mailers.member_mailer.app_no_uploaded_files'

    let(:applicant) { create(:user_with_membership_app, email: 'user_new@example.com') }

    let(:email_sent) { MemberMailer.app_no_uploaded_files(applicant) }

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: NO_UPLOADED_FILES_SCOPE),
                    'user_new@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'it shows how to login and the page to upload files' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  describe 'hbranding_fee_will_expire' do

    HBRAND_FEE_WILLEXPIRE_SCOPE = 'mailers.member_mailer.h_branding_fee_will_expire'
    let(:email_sent) { MemberMailer.h_branding_fee_will_expire(company, test_member) }


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: HBRAND_FEE_WILLEXPIRE_SCOPE),
                    'member@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'tells you when the HBranding license will expire' do
      expect(email_sent).to have_body_text(I18n.t('message_text.expire_alert_html',
                                                  scope:       HBRAND_FEE_WILLEXPIRE_SCOPE,
                                                  expire_date: company.branding_expire_date))
    end

    it_behaves_like 'it shows how to login and the page to pay the H-markt fee' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end
  end


  describe 'first_membership_fee_owed' do

    FIRST_MEMBERSHIP_OWED_SCOPE = 'mailers.member_mailer.first_membership_fee_owed'
    let(:approved_user) { create(:user_with_membership_app, application_status: :accepted,
                                 email: 'approved-user@example.com')}
    let(:email_sent) { MemberMailer.first_membership_fee_owed(approved_user) }


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: FIRST_MEMBERSHIP_OWED_SCOPE),
                    'approved-user@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'it shows how to login and the page to pay the membership fee' do
      let(:email_created) { email_sent }
      let(:user) { approved_user }
    end

    it 'tells you to pay the membership fee' do
      expect(email_sent).to have_body_text(I18n.t('message_text', scope: FIRST_MEMBERSHIP_OWED_SCOPE))
    end
  end


  describe 'membership_renewed' do

    MEMBERSHIP_RENEWED_SCOPE = 'mailers.member_mailer.membership_renewed'

    let!(:incomplete_co) do
      incomplete_company = create(:company, name: 'Incomplete')
      incomplete_company.name = ''
      test_member.shf_application.companies << incomplete_company
      incomplete_company
    end

    let!(:expired_co) do
      expired = create(:company, name: 'Expired')
      # TODO when Company uses Membership, then change this to (from using payments)
      create(:h_branding_fee_payment, user: test_member, company: expired,
             expire_date: Date.current - 1.day )
      test_member.shf_application.companies << expired
      expired
    end

    let(:email_sent) { MemberMailer.membership_renewed(test_member) }


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: MEMBERSHIP_RENEWED_SCOPE),
                    'member@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

    it 'it is awesome that you renewed' do
      expect(email_sent).to have_body_text(I18n.t('message_text.awesome', scope: MEMBERSHIP_RENEWED_SCOPE))
    end

    it 'shows the last day of the membership' do
      expect(email_sent).to have_body_text(I18n.t('message_text.renewed_last_day', scope: MEMBERSHIP_RENEWED_SCOPE))
    end


    describe 'lists all companies the member belongs to' do

      it 'companies you belong to:' do
        expect(email_sent).to have_body_text(I18n.t('message_text.companies_you_belong_to', scope: MEMBERSHIP_RENEWED_SCOPE))
      end

      it 'warns about 1 incomplete company' do
        expect(email_sent).to  have_body_text(I18n.t('.message_text.company-incomplete', scope: MEMBERSHIP_RENEWED_SCOPE))
      end

      it 'warns about 1 expired company' do
        expect(email_sent).to  have_body_text(I18n.t('.message_text.company-license-expired', scope: MEMBERSHIP_RENEWED_SCOPE))
      end

      describe 'shows for each company:' do

        # Assumes that renewal_company is defined in a let statement, etc.
        shared_examples 'it shows name, number, expiration for the company' do | co_description |

          it("name for #{co_description}") { expect(email_sent).to have_body_text(renewal_company.name) }

          it("company number for #{co_description}") { expect(email_sent).to have_body_text(renewal_company.company_number) }

          it("h-markt license last day for #{co_description}") { expect(email_sent).to have_body_text(renewal_company.branding_expire_date.to_s) }
        end


        it_behaves_like 'it shows name, number, expiration for the company', 'Co. in good standing'  do
          let(:renewal_company) { company }
        end
        it_behaves_like 'it shows name, number, expiration for the company', 'Incomplete company' do
          let(:renewal_company) { incomplete_co }
        end
        it_behaves_like 'it shows name, number, expiration for the company', 'Expired H-Markt lic.' do
          let(:renewal_company) { expired_co }
        end
      end
    end

    it_behaves_like 'it shows how to login and the page to pay the H-markt fee' do
      let(:email_created) { email_sent }
    end


    it 'thanks for being a member for another year' do
      expect(email_sent).to have_body_text(I18n.t('message_text.thanks', scope: MEMBERSHIP_RENEWED_SCOPE))
    end
  end


  it 'has a previewer' do
    expect(MemberMailerPreview).to be
  end

end
