require 'rails_helper'

RSpec.describe Visitor, type: :model do

  shared_examples_for 'a user' do
    it { should respond_to(:admin?) }
    it { should respond_to(:is_member?) }
    it { should respond_to(:is_member_or_admin?) }
    it { should respond_to(:has_membership_application?) }
    it { should respond_to(:has_company?) }
    it { should respond_to(:is_in_company_numbered?) }
  end

  describe Visitor do
    subject { Visitor.new }
    it_should_behave_like 'a user'
  end

  describe User do
    subject { FactoryGirl.create(:user) }
    it_should_behave_like 'a user'
  end
end
