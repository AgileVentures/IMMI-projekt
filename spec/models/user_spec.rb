require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'DB table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :encrypted_password }
    it { is_expected.to have_db_column :street }
    it { is_expected.to have_db_column :postal_code }
    it { is_expected.to have_db_column :city }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :business_number }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :encrypted_password }
    it { is_expected.to validate_presence_of :street }
    it { is_expected.to validate_presence_of :postal_code }
    it { is_expected.to validate_presence_of :city }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :password }

    it { is_expected.to validate_confirmation_of :password }
    it { is_expected.to validate_confirmation_of :email }
    it { is_expected.to validate_length_of :password }
  end

  describe 'Factory' do
    it 'should have valid Factory' do
      expect(FactoryGirl.create(:user)).to be_valid
    end
  end

  describe 'Email validations' do
    it 'should have an @' do
      expect(FactoryGirl.build(:user, email: "sussimmi.nu", email_confirmation: "sussimmi.nu")).not_to be_valid
    end
    it 'should have a .' do
      expect(FactoryGirl.build(:user, email: "suss@imminu", email_confirmation: "suss@imminu")).not_to be_valid
    end
    it 'should not have a space' do
      expect(FactoryGirl.build(:user, email: "su ss@immi.nu", email_confirmation: "su ss@immi.nu")).not_to be_valid
    end
    it 'shold validate case insensitively' do
      expect(FactoryGirl.create(:user)).to validate_uniqueness_of(:email).case_insensitive
    end
  end

end
