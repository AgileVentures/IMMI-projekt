require 'rails_helper'

RSpec.describe Condition, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(build(:condition)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :class_name }
    it { is_expected.to have_db_column :timing }
    it { is_expected.to have_db_column :config }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:class_name) }
  end

  describe 'required attributes' do
    let(:example_condition) do
      create(:condition, class_name: 'MembershipExpireAlert',
                         name: 'membership_will_expire',
                         timing: 'before',
                         config: { days: [10, 5, 2] })
    end
    it 'class_name is required' do
      expect(example_condition).to be_valid
      example_condition.update_column(:class_name, nil)
      expect(example_condition).not_to be_valid
    end

    it 'other attributes optional' do
      expect(example_condition).to be_valid
      example_condition.update_attributes(name: nil, timing: nil, config: nil)
      expect(example_condition).to be_valid
    end
  end
end
