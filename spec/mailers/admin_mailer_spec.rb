require 'rails_helper'
require 'email_spec/rspec'


require File.join(__dir__, 'shared_email_tests')

require_relative './previews/admin_mailer_preview'

# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct
#
RSpec.describe AdminMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:test_user) { create(:user, email: 'user@example.com') }


  describe '#new_member_application_received' do

    let(:new_app) { create(:shf_application, user: test_user)  }
    let(:admin) { create(:user, email: 'admin@example.com', admin: true) }
    let(:email_sent) { AdminMailer.new_shf_application_received(new_app, admin) }

    it_behaves_like 'a successfully created email',
                    I18n.t('mailers.admin_mailer.new_application_received.subject'),
                    'admin@example.com',
                    'Firstname Lastname',
                    I18n.t('mailers.admin_mailer.signoff') do
      let(:email_created) { email_sent }
    end


    it 'has text for the number of files uploaded' do
      expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.many'))
    end

    describe 'shows the number of files uploaded' do

      UPLOAD_FIXTURES_DIR = File.join(Rails.root, 'spec', 'fixtures','uploaded_files')

      it 'no files uploaded' do
        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.many') + ': 0')
      end

      it '1 file uploaded' do
        fn1 = File.join(UPLOAD_FIXTURES_DIR, 'diploma.pdf')
        new_app.uploaded_files.create(actual_file: File.open(fn1, 'r') )

        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.many') + ': 1')
      end

      it '3 files uploaded' do
        fn1 = File.join(UPLOAD_FIXTURES_DIR, 'diploma.pdf')
        new_app.uploaded_files.create(actual_file: File.open(fn1, 'r') )
        fn2 = File.join(UPLOAD_FIXTURES_DIR, 'image.jpg')
        new_app.uploaded_files.create(actual_file: File.open(fn2, 'r') )
        fn3 = File.join(UPLOAD_FIXTURES_DIR, 'image.gif')
        new_app.uploaded_files.create(actual_file: File.open(fn3, 'r') )

        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.many') + ': 3')
      end
    end


    it 'has the company number' do
      expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.company.company_number'))
      expect(email_sent).to have_body_text(new_app.companies.first.company_number)
    end

  end


  it 'has a previewer' do
    expect(AdminMailerPreview).to be
  end


end
