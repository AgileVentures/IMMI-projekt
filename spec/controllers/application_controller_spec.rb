require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do


  describe '#test_exception_notifications' do

    before(:each) { ExceptionNotifier.testing_mode! }
    after(:each)  { ExceptionNotifier.testing_mode = false }


    it 'message for notification = this is just a test' do
      expect{subject.test_exception_notifications}.to raise_error(RuntimeError, 'This is a just a test of the exception notifications to ensure they are working.')
    end

  end


end
