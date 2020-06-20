require 'rails_helper'

RSpec.describe ShfApplicationsHelper, type: :helper do

  describe '#states_selection_list gets the localized version of each state name each time it is requested' do
    let(:application) { create(:shf_application) }

    it 'returns the list in the default I18n locale' do
      select_list = helper.states_selection_list
      select_list.each do |each_option|
        expect(each_option[0]).to eq I18n.t("activerecord.attributes.shf_application.state/#{each_option[1]}")
      end
    end

    it 'correct locale if changed to :en from locale = :sv' do
      I18n.locale = :sv
      helper.states_selection_list

      I18n.locale = :en
      select_list = helper.states_selection_list
      select_list.each do |each_option|
        expect(each_option[0]).to eq I18n.t("activerecord.attributes.shf_application.state/#{each_option[1]}", locale: :en)
      end

    end
  end

  describe 'returns a list of reasons_for_waiting for the right locale' do

    before(:each) do
      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv1', name_en: 'name_en1', description_sv: 'desc_sv1', description_en: 'desc_en1')
      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv2', name_en: 'name_en2', description_sv: 'desc_sv2', description_en: 'desc_en2')
      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv3', name_en: 'name_en3', description_sv: 'desc_sv3', description_en: 'desc_en3')
    end

    let(:reason1) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv1') }
    let(:reason2) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv2') }
    let(:reason3) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv3') }

    describe '#reasons_for_waiting_names' do

      let(:expected_sv_names) { [[reason1.id, 'name_sv1'], [reason2.id, 'name_sv2'], [reason3.id, 'name_sv3']] }
      let(:expected_en_names) { [[reason1.id, 'name_en1'], [reason2.id, 'name_en2'], [reason3.id, 'name_en3']] }

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

      let(:expected_sv_descs) { [[reason1.id, 'desc_sv1'], [reason2.id, 'desc_sv2'], [reason3.id, 'desc_sv3']] }
      let(:expected_en_descs) { [[reason1.id, 'desc_en1'], [reason2.id, 'desc_en2'], [reason3.id, 'desc_en3']] }

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


  describe "#reasons_collection appends an 'other' reason with name from the locale file" do

    it 'other reason is at the end of the list' do

      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv1', name_en: 'name_en1', description_sv: 'desc_sv1', description_en: 'desc_en1')
      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv2', name_en: 'name_en2', description_sv: 'desc_sv2', description_en: 'desc_en2')

      last_r = helper.reasons_collection(-999, 'other').last
      expect(last_r.name_sv).to eq 'other'
      expect(last_r.id).to eq(-999)

    end

    it "locale = default ( == sv); sets the name_sv" do
      last_r = helper.reasons_collection(-999, 'other').last
      expect(last_r.name_sv).to eq 'other'
      expect(last_r.name_en).to be_nil
    end

    it 'locale = sv; sets the name_sv' do
      last_r = helper.reasons_collection(-999, 'other').last
      expect(last_r.name_sv).to eq 'other'
      expect(last_r.name_en).to be_nil
    end

    it 'locale = en; sets the name_en' do
      I18n.locale = :en
      last_r = helper.reasons_collection(-999, 'other').last
      expect(last_r.name_sv).to be_nil
      expect(last_r.name_en).to eq 'other'
    end

  end

  describe '#selected_reason_value' do

    let(:member_app) { create(:shf_application) }

    it '@other_reason_value if there is something in custom reason text' do
      member_app.custom_reason_text = 'something'
      expect(helper.selected_reason_value(member_app, -999)).to eq(-999)
    end


    describe 'member_app_waiting_reasons_id if there is not something in custom reason text' do

      it 'member_app_waiting_reasons_id if custom_reason_text == empty string ' do
        member_app.custom_reason_text = ''
        expect(helper.selected_reason_value(member_app, -999)).to eq member_app.member_app_waiting_reasons_id
      end

      it 'member_app_waiting_reasons_id if custom_reason_text == nil' do
        member_app.custom_reason_text = nil
        expect(helper.selected_reason_value(member_app, -999)).to eq member_app.member_app_waiting_reasons_id
      end

    end

  end

  describe '#list_app_categories' do
    let(:category1) { create(:business_category, name: 'category1') }
    let(:category2) { create(:business_category, name: 'category2') }
    let(:category3) { create(:business_category, name: 'category3') }
    let(:application) { create(:shf_application, num_categories: 0,
                               business_categories: [category1, category2, category3]) }

    it 'returns list of categories for an application' do
      expect(list_app_categories(application))
        .to eq('category1, category2, category3')
    end
  end

  describe '#file_delivery_radio_buttons_collection' do

    let(:collection_sv)  do
      I18n.locale = :sv
      file_delivery_radio_buttons_collection.first
    end

    let(:collection_en)  do
      I18n.locale = :en
      file_delivery_radio_buttons_collection.first
    end

    let(:footnotes_sv)  do
      I18n.locale = :sv
      file_delivery_radio_buttons_collection.second
    end

    let(:footnotes_en)  do
      I18n.locale = :en
      file_delivery_radio_buttons_collection.second
    end

    let!(:upload_now) { create(:file_delivery_upload_now) }
    let!(:upload_later) { create(:file_delivery_upload_later) }
    let!(:email) { create(:file_delivery_email) }
    let!(:mail) { create(:file_delivery_mail) }
    let!(:files_uploaded) { create(:file_delivery_files_uploaded) }

    it 'includes all options in DB' do
      expect(collection_sv.count).to eq 5
    end

    it 'returns option descriptions (with footnotes indicators) - swedish' do
      expect(collection_sv).to contain_exactly(
        [upload_now.id, upload_now.description_sv],
        [upload_later.id, upload_later.description_sv],
        [email.id, email.description_sv + '*'],
        [mail.id, mail.description_sv + '**'],
        [files_uploaded.id, files_uploaded.description_sv]
      )
    end

    it 'returns option descriptions (with footnotes indicators) - english' do
      expect(collection_en).to contain_exactly(
        [upload_now.id, upload_now.description_en],
        [upload_later.id, upload_later.description_en],
        [email.id, email.description_en + '*'],
        [mail.id, mail.description_en + '**'],
        [files_uploaded.id, files_uploaded.description_en]
      )
    end

    it 'returns option footnotes - swedish' do
      I18n.locale = :sv
      expect(footnotes_sv).to match(/\*.*#{ENV['SHF_MEMBERSHIP_EMAIL']}/)
      expect(footnotes_sv).to match(/#{t('shf_applications.new.where_to_mail_files')}/)
    end

    it 'returns option footnotes - english' do
      I18n.locale = :en
      expect(footnotes_sv).to match(/\*.*#{ENV['SHF_MEMBERSHIP_EMAIL']}/)
      expect(footnotes_sv).to match(/#{t('shf_applications.new.where_to_mail_files')}/)
    end

    it 'orders default option (upload) as first in list of buttons' do
      expect(collection_en.first).to eq [upload_now.id, upload_now.description_en]
    end
  end

  describe '#file_delivery_method_status' do

    it 'shows "none" (with no date) if no delivery method has been specified' do
      app = create(:shf_application, :legacy_application)
      fdm_msg = file_delivery_method_status(app)

      expect(fdm_msg).to match(/^#{I18n.t('shf_applications.show.files_delivery_method')}/)
      expect(fdm_msg).to match(/#{I18n.t('none_plur')}/)
      expect(fdm_msg).to_not match(/#{Date.current}/)
    end

    it 'shows chosen delivery method with date' do

      AdminOnly::FileDeliveryMethod::METHOD_NAMES.values.each do |fdm_name|

        app = create(:shf_application,
                     file_delivery_method: create("file_delivery_#{fdm_name}".to_sym))

        fdm = app.file_delivery_method
        fdm_msg = file_delivery_method_status(app)

        expect(fdm_msg).to match(/^#{I18n.t('shf_applications.show.files_delivery_method')}/)
        expect(fdm_msg).to match(/#{fdm.description_for_locale(I18n.locale)}/)
        expect(fdm_msg).to match(/#{Date.current}/)
      end
    end
  end
end
