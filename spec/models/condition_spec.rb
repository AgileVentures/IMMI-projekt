require 'rails_helper'

RSpec.describe Condition, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:condition)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :class_name }
    it { is_expected.to have_db_column :timing }
    it { is_expected.to have_db_column :config }
  end
end
