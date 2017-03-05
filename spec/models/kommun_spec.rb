require 'rails_helper'

RSpec.describe Kommun, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:kommun)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
  end

  describe 'Associations' do
    it { is_expected.to have_many :addresses }
  end
end
