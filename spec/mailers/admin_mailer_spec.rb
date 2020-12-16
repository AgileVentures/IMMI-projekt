require 'rails_helper'
require 'email_spec/rspec'
require 'shared_context/companies'
require 'shared_context/users'
require 'shared_context/named_dates'

require File.join(__dir__, 'shared_email_tests')

require_relative './previews/admin_mailer_preview'

# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct
#
RSpec.describe AdminMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:test_user) { create(:user, email: 'user@example.com') }
  let(:admin) { create(:user, email: 'admin@example.com', admin: true) }


  describe '#new_shf_application_received' do

    let(:new_app) { create(:shf_application, user: test_user) }
    let!(:email_sent) { AdminMailer.new_shf_application_received(new_app, admin) }

    it_behaves_like 'a successfully created email',
                    I18n.t('mailers.admin_mailer.new_application_received.subject'),
                    'admin@example.com',
                    'Firstname Lastname',
                    I18n.t('mailers.admin_mailer.signoff') do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

    it 'has text for the number of files uploaded' do
      expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.other'))
    end

    describe 'shows the number of files uploaded' do

      UPLOAD_FIXTURES_DIR = File.join(Rails.root, 'spec', 'fixtures', 'uploaded_files')

      it 'no files uploaded' do
        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.other') + ': 0')
      end

      it '1 file uploaded' do
        fn1 = File.join(UPLOAD_FIXTURES_DIR, 'diploma.pdf')
        new_app.uploaded_files << create(:uploaded_file_for_application, actual_file: File.open(fn1, 'r'), shf_application: new_app)
        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.other') + ': 1')
      end

      it '3 files uploaded' do
        fn1 = File.join(UPLOAD_FIXTURES_DIR, 'diploma.pdf')
        new_app.uploaded_files << create(:uploaded_file_for_application, actual_file: File.open(fn1, 'r'), shf_application: new_app)
        fn2 = File.join(UPLOAD_FIXTURES_DIR, 'image.jpg')
        new_app.uploaded_files  << create(:uploaded_file_for_application, actual_file: File.open(fn2, 'r'), shf_application: new_app)
        fn3 = File.join(UPLOAD_FIXTURES_DIR, 'image.gif')
        new_app.uploaded_files << create(:uploaded_file_for_application, actual_file: File.open(fn3, 'r'), shf_application: new_app)

        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.other') + ': 3')
      end
    end


    it 'has the company number' do
      expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.company.company_number'))
      expect(email_sent).to have_body_text(new_app.companies.first.company_number)
    end

  end


  describe '#member_unpaid_over_x_months' do

    let(:new_app) { create(:shf_application, user: test_user) }

    let(:mon_ago_5) { Time.zone.now - 5.months }

    let(:past_member1) do
      memb = create(:member_with_expiration_date, expiration_date: mon_ago_5, first_name: 'Member1')
      memb.companies.first.update(website: 'website1')
      memb.issue_membership_number
      memb
    end

    let(:past_member2) do
      memb = create(:member_with_expiration_date, expiration_date: mon_ago_5, first_name: 'Member2')
      memb.companies.first.update(website: 'website2')
      memb.issue_membership_number
      memb
    end

    let(:past_member3) do
      memb = create(:member_with_expiration_date, expiration_date: mon_ago_5, first_name: 'Member3')
      memb.companies.first.update(website: 'website3')
      memb.issue_membership_number
      memb
    end

    let(:members_5_mon_overdue) { [past_member1, past_member2, past_member3] }

    let(:num_months) { 5 }
    let(:email_sent) { AdminMailer.member_unpaid_over_x_months(admin, members_5_mon_overdue, num_months) }


    describe 'number of months' do

      it 'defaults to 6 months' do

        # have to stub out all these translate calls so we can catch the 1 with :num_months
        allow(I18n).to receive(:translate).with(anything, { raise: true }).and_return('ok')
        allow(I18n).to receive(:translate).with('full_name', anything).and_return('ok')
        allow(I18n).to receive(:translate).with("these_are_unpaid", anything).and_return('ok')
        allow(I18n).to receive(:translate).with("mailers.application_mailer.greeting", anything).and_return('ok')
        allow(I18n).to receive(:translate).with("mailers.application_mailer.footer.text.email_sent_to", anything).and_return('ok')

        expect(I18n).to receive(:translate).with('member_unpaid_over_x_months.subject',
                                                 { num_months: 6, scope: 'mailers.admin_mailer' })

        subject.member_unpaid_over_x_months(admin, members_5_mon_overdue)
      end

    end

    describe 'lists members not paid for X months' do

      it 'name, membership number, and website is listed' do

        expect(email_sent).to have_body_text('Member1 Lastname')
        expect(email_sent).to have_body_text('Member2 Lastname')
        expect(email_sent).to have_body_text('Member3 Lastname')

        expect(email_sent).to have_body_text(past_member1.membership_number)
        expect(email_sent).to have_body_text(past_member2.membership_number)
        expect(email_sent).to have_body_text(past_member3.membership_number)

        expect(email_sent).to have_body_text('website1')
        expect(email_sent).to have_body_text('website2')
        expect(email_sent).to have_body_text('website3')

      end

      it 'if there is more than 1 company, websites for all companies are shown' do
        past_member2.shf_application.companies.append(past_member1.companies.first)

        # order can be either website2 website1 OR website1 website2
        expect(email_sent).to have_body_text(/((website1 website2)|(website2 website1))/)
      end

    end

    it_behaves_like 'a successfully created email',
                    I18n.t('mailers.admin_mailer.member_unpaid_over_x_months.subject', num_months: 5),
                    ENV['SHF_MEMBERSHIP_EMAIL'],
                    'Firstname Lastname',
                    I18n.t('mailers.admin_mailer.signoff') do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  describe 'new_membership_granted_co_hbrand_paid' do

    include_context 'named dates'
    include_context 'create users'
    include_context 'create companies'

    before do
      Timecop.freeze(jan_30) # must do this so that we know if/when payments/terms expire, etc.
    end

    after do
      Timecop.return
    end


    FACEBOOK_FAUX_URL = 'https://example.com/Fake/Facebook/URL'

    let(:i18nscope) { 'mailers.admin_mailer.new_membership_granted_co_hbrand_paid.message_text' }

    let(:member_1co) do
      member = user_membership_expires_EOD_jan29
      member.first_name = 'Member_1co'
      member.membership_number = '1234567890'
      member.shf_application.business_categories << create(:business_category, name: 'Cat2')
      #member.shf_application.companies.each{|co| co.update(facebook_url: FACEBOOK_FAUX_URL) }
      member
    end
    let!(:email_sent) { AdminMailer.new_membership_granted_co_hbrand_paid(member_1co) }


    # User Full Name
    #Company Name
    #Company Post (snail mail) Address
    #Company website & Facebook (when added)
    #
    #Categories applied for
    #(subcategories when added)

    it_behaves_like 'the recipient is the membership chair' do
      let(:email_created) { email_sent }
    end

    describe 'for each new member listed, shows:' do

      it 'full name' do
        expect(email_sent).to have_body_text("<p class='full-name'>Member_1co Lastname</p>")
      end

      describe 'categories' do

        it 'all categories' do
          expect(email_sent).to have_body_text("<p class='categories'><span class=\"label\">#{I18n.t('categories', scope: i18nscope) }</span>: <span class=\"value\">Business Category, Cat2</span></p>")
        end

        it 'no categories shows an empty string' do
          member_no_categories = user_membership_expires_EOD_jan29
          member_no_categories.first_name = 'Member'
          member_no_categories.last_name = 'NoCats'
          member_no_categories.shf_application.business_categories.delete_all

          no_cats_email_sent = AdminMailer.new_membership_granted_co_hbrand_paid(member_no_categories)

          expect(no_cats_email_sent).to have_body_text("<p class='categories'><span class=\"label\">#{I18n.t('categories', scope: i18nscope) }</span>: <span class=\"value\"></span></p>")
        end
      end


      it 'membership number' do
        # <p class='membership-numbere'><span class=\"label\">member #</span>: <span class=\"value\">1234567890</span></p>
        expect(email_sent).to have_body_text("<p class='membership-number'><span class=\"label\">#{I18n.t('member_number', scope: i18nscope) }</span>: <span class=\"value\">1234567890</span></p>")
      end
    end


    describe 'for each company listed, shows:' do

      it 'company name' do
        expect(email_sent).to have_body_text("<p class='company-name'><span class=\"label\">#{I18n.t('company', scope: i18nscope) }</span>: <span class=\"value\">SomeCompany</span></p>")
      end

      it 'website' do
        expect(email_sent).to have_body_text("<p class='company-website'><span class=\"label\">#{I18n.t('company_website', scope: i18nscope) }</span>:  <span class=\"value\">http://www.example.com</span></p>")
      end

      describe 'facebook URL' do

        skip 'Need to uncomment these tests once the social icons PR is merged'

        #  it 'exists' do
        #    expect(email_sent).to have_body_text("<p class='company-facebook-url'><span class=\"label\">#{I18n.t('company_facebook_url', scope: i18nscope) }</span>: <span class=\"value\">#{FACEBOOK_FAUX_URL}</span></p>")
        #  end
        #
        #  it 'nothing listed if none entered for the company' do
        #    member_co_no_facebook = user_membership_expires_EOD_jan29
        #    member_co_no_facebook.first_name = 'Member'
        #    member_co_no_facebook.last_name = 'NoFacebookUrl'
        #    member_co_no_facebook.shf_application.companies.each { |co| co.update(facebook_url: '') }
        #
        #    no_facebook_email_sent = AdminMailer.new_membership_granted_co_hbrand_paid(member_co_no_facebook)
        #
        #    expect(no_facebook_email_sent).not_to have_body_text("<p class='company-facebook-url'>")
        #  end
      end

      it 'main postal address shows as 1 string' do
        expect(email_sent).to have_body_text("<p class='company-postal-address'><span class=\"label\">#{I18n.t('company_postal_address', scope: i18nscope) }</span>: <span class=\"value\">\"Hundforetagarevägen 1\",'310 40,\"Harplinge\",Ale,MyString,Sverige</span></p>")
      end
    end


    it 'lists all companies for the new member if more than one' do

      co_1_name = 'No More Snarky Barky'
      co_1 = create(:company, name: co_1_name)
      co_2_name = 'Happy Mutts'
      co_2 = create(:company, name: co_2_name)

      member_2_cos = create(:member_with_membership_app, company_number: co_1.company_number)
      member_2_cos.shf_application.companies << co_2

      create(:membership_fee_payment, user: member_2_cos)
      create(:h_branding_fee_payment, user: member_2_cos, company: co_1)
      create(:h_branding_fee_payment, user: member_2_cos, company: co_2)

      member_2_cos_email_sent = AdminMailer.new_membership_granted_co_hbrand_paid(member_2_cos)

      expect(member_2_cos_email_sent).to have_body_text("<p class='company-name'><span class=\"label\">#{I18n.t('company', scope: i18nscope) }</span>: <span class=\"value\">#{co_1_name}</span></p>")
      expect(member_2_cos_email_sent).to have_body_text("<p class='company-name'><span class=\"label\">#{I18n.t('company', scope: i18nscope) }</span>: <span class=\"value\">#{co_2_name}</span></p>")
    end


    # |subject, recipient, greeting_name, signoff, signature|
    it_behaves_like 'a successfully created email',
                    I18n.t('mailers.admin_mailer.new_membership_granted_co_hbrand_paid.subject'),
                    ENV['SHF_MEMBERSHIP_EMAIL'],
                    '',
                    I18n.t('mailers.admin_mailer.signoff') do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  describe 'members_need_packets - is sent to membership email' do

    let(:members_needing_packets) { [] }
    let!(:email_sent) { described_class.members_need_packets(members_needing_packets) }

    it_behaves_like 'the recipient is the membership chair' do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'a successfully created email',
                    I18n.t('mailers.admin_mailer.members_need_packets.subject'),
                    ENV['SHF_MEMBERSHIP_EMAIL'],
                    'membership@example.org',
                    I18n.t('mailers.admin_mailer.signoff') do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end


  it 'has a previewer' do
    expect(AdminMailerPreview).to be
  end

end
