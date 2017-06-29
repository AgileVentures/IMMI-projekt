require 'rails_helper'

RSpec.describe AdminOnly::MemberAppWaitingReason, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:member_app_waiting_reason)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name_sv }
    it { is_expected.to have_db_column :description_sv }
    it { is_expected.to have_db_column :name_en }
    it { is_expected.to have_db_column :description_en }
    it { is_expected.to have_db_column :is_custom }
  end


  describe 'Validations' do

    it { is_expected.to validate_presence_of :name_sv }

  end


end
