require 'rails_helper'
require 'email_spec/rspec'

require File.join(__dir__, 'shared_email_tests')


# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct
#
RSpec.describe AdminMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:test_user) { create(:user, email: 'user@example.com') }


  describe '#member_application_received' do

    let(:new_app) { create(:membership_application, user: test_user)  }
    let(:email_sent) { AdminMailer.member_application_received(new_app) }

    it_behaves_like 'a successfully created email',
                    I18n.t('shf_mailer.admin.new_application_received.subject'),
                    ENV['SHF_MEMBERSHIP_EMAIL'],
                    '' do
      let(:email_created) { email_sent }
    end

  end

end
