require 'rails_helper'
require 'shared_context/users'
require 'shared_context/named_dates'

include ApplicationHelper

RSpec.describe PaymentsHelper, type: :helper do

  let(:user) { create(:user) }
  let(:company) { create(:company) }

  let(:user_payment) do
    create(:payment, user: user,
           status: Payment::ORDER_PAYMENT_STATUS['successful'])
  end
  let(:brand_payment) do
    create(:payment, company: company,
           status: Payment::ORDER_PAYMENT_STATUS['successful'],
           payment_type: Payment::PAYMENT_TYPE_BRANDING)
  end

  # Note that you have to call a helper method preceded with "helper." so that
  # it will correctly find and use the FontAwesome helper method :icon
  # (which is called from expire_date_label_and_value)

  describe 'expire_date_label_and_value' do

    context 'user' do

      let(:member) { create(:member, expiration_date: Date.current + 1.month + 2.days) }

      # which CSS class is tested by the payment_due_now_hint_css_class spec below
      it 'returns the expiration date with the css class set' do
        response = /class="([^"]*)".*#{member.membership_expire_date}/
        expect(helper.expire_date_label_and_value(member)).to match response
      end

      # it 'returns date with style "yes" if expire_date more than a month away' do
      #   user_payment.update(expire_date: Time.zone.today + 1.month + 2.days)
      #   response = /class="Yes".*#{user_payment.expire_date}/
      #   expect(helper.expire_date_label_and_value(user)).to match response
      # end
      #
      # it 'returns date with style "maybe" if expire_date within next month' do
      #   user_payment.update(expire_date: Time.zone.today + 1.month)
      #   response = /class="Maybe".*#{user_payment.expire_date}/
      #   expect(helper.expire_date_label_and_value(user)).to match response
      # end
      #
      # it 'returns date with style "no" if expired' do
      #   user_payment.update(expire_date: Time.zone.today - 1.day)
      #   response = /class="No".*#{user_payment.expire_date}/
      #   expect(helper.expire_date_label_and_value(user)).to match response
      # end

      it 'returns tooltip explaining expiration date' do
        response = /#{t('users.show.membership_expire_date_tooltip')}/
        expect(helper.expire_date_label_and_value(member)).to match response
      end

      it 'no expire date will show Paid through: None' do
        user_no_payments = create(:user)
        response = /.*#{t('users.show.term_paid_through')}.*#{t('none_t')}/
        expect(helper.expire_date_label_and_value(user_no_payments)).to match response
      end
    end

    context 'company' do

      # which CSS class is tested by the payment_due_now_hint_css_class spec below
      it 'returns the expiration date with the css class set' do
        brand_payment.update(expire_date: Time.zone.today + 1.month + 2.days)
        response = /class="([^"]*)".*#{brand_payment.expire_date}/
        expect(helper.expire_date_label_and_value(brand_payment.company)).to match response
      end

      # it 'returns date with style "yes" if expire_date more than a month away' do
      #   brand_payment.update(expire_date: Time.zone.today + 1.month + 2.days)
      #   response = /class="Yes".*#{brand_payment.expire_date}/
      #   expect(helper.expire_date_label_and_value(company)).to match response
      # end
      #
      # it 'returns date with style "maybe" if expire_date within next month' do
      #   brand_payment.update(expire_date: Time.zone.today + 1.month)
      #   response = /class="Maybe".*#{brand_payment.expire_date}/
      #   expect(helper.expire_date_label_and_value(company)).to match response
      # end
      #
      # it 'returns date with style "no" if expired' do
      #   brand_payment.update(expire_date: Time.zone.today - 1.day)
      #   response = /class="No".*#{brand_payment.expire_date}/
      #   expect(helper.expire_date_label_and_value(company)).to match response
      # end

      it 'returns tooltip explaining expiration date' do
        brand_payment.update(expire_date: Time.zone.today)
        response = /#{t('companies.show.branding_fee_expire_date_tooltip')}/
        expect(helper.expire_date_label_and_value(company)).to match response
      end

      it 'no expire date will show Paid through: None' do
        co_no_payments = create(:user)
        response = /.*#{t('companies.show.term_paid_through')}.*#{t('none_t')}/
        expect(helper.expire_date_label_and_value(co_no_payments)).to match response
      end
    end
  end

  describe 'entity_name' do

    it 'full name if entity is a User' do
      u = build(:user, first_name:'First', last_name: 'Last')
      expect(helper.entity_name(u)).to eq('First Last')
    end

    it 'name if the entity is a Company' do
      co = build(:company, name: 'Some Company')
      expect(helper.entity_name(co)).to eq('Some Company')
    end

    it "t('name_missing') if entity is nil or not a User and not a Company" do
      else_result = I18n.t('name_missing')
      expect(helper.entity_name(nil)).to eq(else_result)
      expect(helper.entity_name('this string')).to eq(else_result)
    end
  end


  describe 'entity_expire_date' do

    include_context 'create users'
    include_context 'named dates'

    it 'default is nil (if entity is nil)' do
      expect(entity_expire_date).to be_nil
    end

    it 'nil if entity is not a User or Company' do
      expect(entity_expire_date(7)).to be_nil
    end

    it 'entity.membership_expire_date if entity is a User' do
      expect(entity_expire_date(member_expired)).to eq(Time.zone.yesterday)
    end

    it 'entity.branding_expire_date if entity is a Company' do
      co_expired_yesterday = user_membership_expires_EOD_jan30.companies.first
      expect(entity_expire_date(co_expired_yesterday)).to eq(co_expired_yesterday.branding_expire_date)
    end
  end


  describe 'entity_i18n_scope' do

    it 'default is "users"' do
      expect(entity_i18n_scope).to eq 'users'
    end

    it '"users" if the entity is a User' do
      expect(entity_i18n_scope(create(:user))).to eq 'users'
    end

    it '"companies" if the entity is a Company' do
      expect(entity_i18n_scope(create(:company))).to eq 'companies'
    end

    it '"users" if the entity is not a Company or User' do
      expect(entity_i18n_scope(7)).to eq 'users'
    end
  end

  describe 'payment_notes_label_and_value' do

    it "displays t('none_plur)' if there is no text to display" do
      expect(helper).to receive(:field_or_none)
                          .with(anything, I18n.t('none_plur'), anything)
      helper.payment_notes_label_and_value
    end

    it 'returns the HTML for payment notes label and display string (=field value)' do
      note_text = 'This is the payment note.'
      expect(helper).to receive(:field_or_none)
                          .with(anything, note_text, tag: :div)
      helper.payment_notes_label_and_value(note_text)
    end
  end


  describe 'payment_due_hint returns string from I18n.t for the payment_due_status' do

    it 'status = :past_due' do
      faux_user =  build(:member_with_membership_app)
      allow(faux_user).to receive(:payment_due_status).and_return(:past_due)
      expect(payment_due_hint(faux_user)).to eq t('payors.past_due')
    end

    it 'status = :due' do
      faux_user =  build(:member_with_membership_app)
      allow(faux_user).to receive(:payment_due_status).and_return(:due)
      expect(payment_due_hint(faux_user)).to eq t('payors.due')
    end

    it 'status = :due_by also requires a due_date' do
      faux_user =  build(:member_with_membership_app)
      allow(faux_user).to receive(:payment_due_status).and_return(:due_by)
      allow(faux_user).to receive(:payment_expire_date).and_return(Date.new(2019,11,11))
      expect(payment_due_hint(faux_user)).to eq t('payors.due_by', due_date: '2019-11-11')
    end

    it 'status = :too_early' do
      faux_user =  build(:member_with_membership_app)
      allow(faux_user).to receive(:payment_due_status).and_return(:too_early)
      expect(payment_due_hint(faux_user)).to eq t('payors.too_early')
    end
  end


  describe 'payment_due_now_hint_css_class is based on entity.should_pay_now? and entity.too_early_to_pay?' do

    it 'returns yes css class if payment status is :too_early' do
      faux_user =  build(:member_with_membership_app)
      allow(faux_user).to receive(:payment_due_status).and_return(:too_early)
      expect(payment_due_now_hint_css_class(faux_user)).to eq helper.yes_css_class
    end

    it 'returns maybe css class if payment status is :due_by' do
      faux_user =  build(:member_with_membership_app)
      allow(faux_user).to receive(:payment_due_status).and_return(:due_by)
      expect(payment_due_now_hint_css_class(faux_user)).to eq helper.maybe_css_class
    end

    it 'returns no css class if the payment status is :past_due' do
      faux_user =  build(:member_with_membership_app)
      allow(faux_user).to receive(:payment_due_status).and_return(:past_due)
      expect(payment_due_now_hint_css_class(faux_user)).to eq helper.no_css_class
    end

    it 'returns no css class if payment status is :due' do
      faux_user =  build(:member_with_membership_app)
      allow(faux_user).to receive(:payment_due_status).and_return(:due)
      expect(payment_due_now_hint_css_class(faux_user)).to eq helper.no_css_class

      faux_co = build(:company)
      allow(faux_co).to receive(:payment_due_status).and_return(:due)
      expect(payment_due_now_hint_css_class(faux_co)).to eq helper.no_css_class
    end

  end




  describe 'expires_soon_hint_css_class' do

    it 'returns yes css class if expire_date more than a month away' do
      expect(expires_soon_hint_css_class(Time.zone.today + 2.months)).to eq helper.yes_css_class
    end

    it 'returns maybe css class if expire_date less than a month away' do
      expect(expires_soon_hint_css_class(Time.zone.today + 2.days)).to eq helper.maybe_css_class
    end

    it 'returns no css class if expire_date has passed' do
      expect(expires_soon_hint_css_class(Time.zone.today - 2.days)).to eq helper.no_css_class
    end
  end


  describe 'payment_button_classes' do

    it 'default is to return %w(btn btn-secondary btn-sm)' do
      expect(payment_button_classes).to match_array(['btn', 'btn-secondary', 'btn-sm'])
    end

    it 'adds any given classes to the list of the default ones (order not important)' do
      expect(payment_button_classes(['another class', 'class2'])).to match_array(['btn', 'btn-secondary', 'btn-sm', 'another class', 'class2'])
    end
  end


  describe 'payment_button_tooltip_text' do

    describe 'i18n scope' do

      it "default is 'users'" do
        expect(payment_button_tooltip_text).to eq t("users.show.payment_tooltip")
      end

      it 'pass in a different scope' do
        expect(payment_button_tooltip_text(t_scope: 'companies')).to eq t("companies.show.payment_tooltip")
      end

      it 'if given i18n scope not found, will use "users" scope' do
        expect(payment_button_tooltip_text(t_scope: 'blorf')).to eq t("users.show.payment_tooltip")
      end
    end

    describe 'payment_due_now determines if "no payment due now" message shows' do

      it 'default is true (does not show "no payment due now" message)' do
        expect(payment_button_tooltip_text).not_to include t('payors.no_payment_due_now')
      end

      it 'false will show "no payment due now" message' do
        expect(payment_button_tooltip_text(payment_due_now: false)).to include t('payors.no_payment_due_now')
      end
    end

  end

end
