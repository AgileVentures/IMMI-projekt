require 'rails_helper'
require 'support/validator_helper'
include ValidatorHelper

RSpec.describe EmailValidator do
  let(:model) { ValidatorHelper.test_model_class }
  let(:record) { model.new }

  let(:error_msg) { I18n.t('errors.messages.invalid') }

  before(:each) do
    record.class_eval do
      validates :test_attr, email: true
    end
  end

  shared_examples 'invalid email adds to error messages' do | invalid_email|

    it "#{invalid_email} adds to error messages" do
      some_model = ValidatorHelper.test_model_class.new
      some_model.class_eval do
        validates :test_attr, email: true
      end

      some_model.errors.clear
      some_model.test_attr = invalid_email
      expect { some_model.valid? }
        .to change(some_model.errors, :messages)
              .from({})
              .to a_hash_including(test_attr: ["#{error_msg}: #{invalid_email}"])
    end
  end

  it_behaves_like 'invalid email adds to error messages', 'email.com'
  it_behaves_like 'invalid email adds to error messages', 'email@.com'
  it_behaves_like 'invalid email adds to error messages', 'no spaces@example.com'
  it_behaves_like 'invalid email adds to error messages', 'nö-äccæñts-or-ün-åscii-charsåäöÅÄÖ@example.com'
  it_behaves_like 'invalid email adds to error messages', '日本人@日人日本人@example.com'


  it 'does not add error message if email is valid' do
    record.test_attr = 'email@mail.com'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)

    record.test_attr = 'email.with-dot@mail.com'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)

    record.test_attr = 'email_with_underscore@mail.com'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)

    record.test_attr = 'email-with-dash@mail.com'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)
  end
end
