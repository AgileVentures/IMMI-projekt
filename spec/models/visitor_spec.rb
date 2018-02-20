require 'rails_helper'

RSpec.describe Visitor, type: :model do

  # Visitor class represents a "user" of the site who is not logged in.
  # An instance of this class responds to certain methods which are typically
  # called on the return value of Devise's "current_user" helper method.
  # The Visitor class allows us to set the value of "current_user" to a
  # Visitor instance when the user is not logged in.  Since this instance
  # responds appropriately to the methods below, there is no need to check
  # if "current_user" is nil before calling methods on the return value of
  # "current_user" (which will either be an instance of User or of Visitor).

  # The methods listed below are used to determine the type of user, and to
  # execute different logic paths based upon that type.
  # If any other such methods are added to the codebase, then that method should
  # be 1) added as an instance method to Visitor, and 2) added to the
  # shared_examples_for block below.

  shared_examples_for 'a user' do
    it { should respond_to(:admin?) }
    it { should respond_to(:member?) }
    it { should respond_to(:member_or_admin?) }
    it { should respond_to(:has_shf_application?) }
    it { should respond_to(:has_company?) }
    it { should respond_to(:in_company_numbered?) }
  end

  describe Visitor do
    subject { Visitor.new }
    it_should_behave_like 'a user'
  end

  describe User do
    subject { FactoryBot.create(:user) }
    it_should_behave_like 'a user'
  end
end
