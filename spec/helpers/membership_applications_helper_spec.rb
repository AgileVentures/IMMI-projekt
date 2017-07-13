require 'rails_helper'

RSpec.describe MembershipApplicationsHelper, type: :helper do

  before(:all) do
    # ensure MembershipAppWaitingReason.all is empty
    AdminOnly::MemberAppWaitingReason.delete_all
  end


  describe '#member_full_name' do
    it 'appends first and last with a space inbetween' do
      assign(:membership_application, create(:membership_application, first_name: 'Kitty', last_name: 'Kat', user: create(:user)))
      expect(helper.member_full_name).to eq('Kitty Kat')
    end

  end

  describe 'returns a list of reasons_for_waiting for the right locale' do

    before(:all) do
      FactoryGirl.create(:member_app_waiting_reason, name_sv: 'name_sv1', name_en: 'name_en1', description_sv: 'desc_sv1', description_en: 'desc_en1')
      FactoryGirl.create(:member_app_waiting_reason, name_sv: 'name_sv2', name_en: 'name_en2', description_sv: 'desc_sv2', description_en: 'desc_en2')
      FactoryGirl.create(:member_app_waiting_reason, name_sv: 'name_sv3', name_en: 'name_en3', description_sv: 'desc_sv3', description_en: 'desc_en3')
    end

    let(:reason1) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv1') }
    let(:reason2) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv2') }
    let(:reason3) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv3') }


    describe '#reasons_for_waiting_names' do

      let(:expected_sv_names) { [ [reason1.id, 'name_sv1'], [reason2.id, 'name_sv2'], [reason3.id, 'name_sv3'] ] }
      let(:expected_en_names) { [ [reason1.id, 'name_en1'], [reason2.id, 'name_en2'], [reason3.id, 'name_en3'] ] }

      it 'calls name_sv if locale == sv' do
        name_list = helper.reasons_for_waiting_names(:sv)
        expect(name_list).to match expected_sv_names
      end

      it 'calls name_en if locale == en' do
        name_list = helper.reasons_for_waiting_names(:en)
        expect(name_list).to match expected_en_names
      end

      it 'calls default_name_method if there is no name method for that locale' do
        name_list = helper.reasons_for_waiting_names(:blorf)
        expect(name_list).to match expected_sv_names
      end

      it 'calls default_name_method if no locale is specified' do
        name_list = helper.reasons_for_waiting_names
        expect(name_list).to match expected_sv_names
      end


      it 'returns a list of [id, text]' do
        name_list = helper.reasons_for_waiting_names
        first_item = name_list.first
        expect(first_item.is_a?(Enumerable)).to be_truthy
        expect(first_item.first.is_a?(Numeric)).to be_truthy
        expect(first_item.last.is_a?(String)).to be_truthy
      end

    end


    describe '#reason_name_method' do

      it 'is :name_sv if locale == :sv' do
        expect(helper.reason_name_method(:sv)).to eq :name_sv
      end

      it 'is :name_en if locale == :en' do
        expect(helper.reason_name_method(:en)).to eq :name_en
      end

      it 'is default name method if there is no desc method for that locale' do
        expect(helper.reason_name_method(:blorf)).to eq AdminOnly::MemberAppWaitingReason.default_name_method
      end

      it 'is default name method if no locale is specified' do
        expect(helper.reason_name_method).to eq AdminOnly::MemberAppWaitingReason.default_name_method
      end

    end


    describe '#reason_description_method' do

      it 'is :desc_sv if locale == :sv' do
        expect(helper.reason_desc_method(:sv)).to eq :description_sv
      end

      it 'is :desc_en if locale == :en' do
        expect(helper.reason_desc_method(:en)).to eq :description_en
      end

      it 'is default desc method if there is no desc method for that locale' do
        expect(helper.reason_desc_method(:blorf)).to eq AdminOnly::MemberAppWaitingReason.default_description_method
      end

      it 'is default desc method if no locale is specified' do
        expect(helper.reason_desc_method).to eq AdminOnly::MemberAppWaitingReason.default_description_method
      end

    end


    describe '#reasons_for_waiting_descs' do

      let(:expected_sv_descs) { [ [reason1.id, 'desc_sv1'], [reason2.id, 'desc_sv2'], [reason3.id, 'desc_sv3'] ] }
      let(:expected_en_descs) { [ [reason1.id, 'desc_en1'], [reason2.id, 'desc_en2'], [reason3.id, 'desc_en3'] ] }

      it 'calls description_sv if locale == sv' do
        desc_list = helper.reasons_for_waiting_descs(:sv)
        expect(desc_list).to match expected_sv_descs
      end

      it 'calls description_en if locale == en' do
        desc_list = helper.reasons_for_waiting_descs(:en)
        expect(desc_list).to match expected_en_descs
      end

      it 'calls default_description_method if there is no desc method for that locale' do
        desc_list = helper.reasons_for_waiting_descs(:blorf)
        expect(desc_list).to match expected_sv_descs
      end

      it 'calls default_description_method if no locale is specified' do
        desc_list = helper.reasons_for_waiting_descs
        expect(desc_list).to match expected_sv_descs
      end


      it 'returns a list of [id, text]' do
        desc_list = helper.reasons_for_waiting_descs
        first_item = desc_list.first
        expect(first_item.is_a?(Enumerable)).to be_truthy
        expect(first_item.first.is_a?(Numeric)).to be_truthy
        expect(first_item.last.is_a?(String)).to be_truthy
      end

    end

  end
end
