require 'rails_helper'

RSpec.describe Region, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:region)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :code }
  end

  describe 'Associations' do
    it { is_expected.to have_many :companies }
  end
end
