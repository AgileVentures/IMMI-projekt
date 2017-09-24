require 'rails_helper'
require 'email_spec/rspec'


require File.join(__dir__, 'shared_email_tests')



# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct
#
RSpec.describe MembershipApplicationMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:test_user) { create(:user, email: 'user@example.com') }


  describe '#accepted' do

    let(:accepted_app) { create(:membership_application, :accepted, user: test_user)  }
    let(:email_sent) { MembershipApplicationMailer.accepted(accepted_app) }

    it_behaves_like 'a successfully created email',
                    I18n.t('shf_mailer.membership_application.accepted.subject'),
                    'user@example.com',
                    I18n.t('shf_mailer.greeting', greeting_name: 'Firstname Lastname') do
      let(:email_created) { email_sent }
    end

  end


  describe '#acknowledge_received' do

    let(:received_app) { create(:membership_application, user: test_user)  }
    let(:email_sent) { MembershipApplicationMailer.acknowledge_received(received_app) }

    it_behaves_like 'a successfully created email',
                    I18n.t('shf_mailer.membership_application.acknowledge_received.subject'),
                    'user@example.com',
                    I18n.t('shf_mailer.greeting', greeting_name: 'Firstname Lastname') do
      let(:email_created) { email_sent }
    end

  end

end
