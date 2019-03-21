require 'rails_helper'
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

      it 'returns date with style "yes" if expire_date more than a month away' do
        user_payment.update(expire_date: Time.zone.today + 1.month + 2.days)
        response = /class="Yes".*#{user_payment.expire_date}/
        expect(helper.expire_date_label_and_value(user)).to match response
      end

      it 'returns date with style "maybe" if expire_date within next month' do
        user_payment.update(expire_date: Time.zone.today + 1.month)
        response = /class="Maybe".*#{user_payment.expire_date}/
        expect(helper.expire_date_label_and_value(user)).to match response
      end

      it 'returns date with style "no" if expired' do
        user_payment.update(expire_date: Time.zone.today - 1.day)
        response = /class="No".*#{user_payment.expire_date}/
        expect(helper.expire_date_label_and_value(user)).to match response
      end

      it 'returns tooltip explaining expiration date' do
        user_payment.update(expire_date: Time.zone.today)
        response = /#{t('users.show.membership_expire_date_tooltip')}/
        expect(helper.expire_date_label_and_value(user)).to match response
      end
    end

    context 'company' do

      it 'returns date with style "yes" if expire_date more than a month away' do
        brand_payment.update(expire_date: Time.zone.today + 1.month + 2.days)
        response = /class="Yes".*#{brand_payment.expire_date}/
        expect(helper.expire_date_label_and_value(company)).to match response
      end

      it 'returns date with style "maybe" if expire_date within next month' do
        brand_payment.update(expire_date: Time.zone.today + 1.month)
        response = /class="Maybe".*#{brand_payment.expire_date}/
        expect(helper.expire_date_label_and_value(company)).to match response
      end

      it 'returns date with style "no" if expired' do
        brand_payment.update(expire_date: Time.zone.today - 1.day)
        response = /class="No".*#{brand_payment.expire_date}/
        expect(helper.expire_date_label_and_value(company)).to match response
      end

      it 'returns tooltip explaining expiration date' do
        brand_payment.update(expire_date: Time.zone.today)
        response = /#{t('companies.show.branding_fee_expire_date_tooltip')}/
        expect(helper.expire_date_label_and_value(company)).to match response
      end
    end
  end

  describe 'payment_notes_label_and_value' do

    it 'returns label and "none" if no notes' do
      response = /#{t('activerecord.attributes.payment.notes')}.*#{t('none')}/
      expect(payment_notes_label_and_value(user)).to match response
    end

    it 'returns label and value if notes' do
      notes = 'here are some notes for this payment'
      user_payment.update(notes: notes)
      response = /#{t('activerecord.attributes.payment.notes')}.*#{notes}/
      expect(payment_notes_label_and_value(user)).to match response
    end
  end

  describe 'expire_date_css_class' do

    it 'returns "Yes" if expire_date more than a month away' do
      expect(expire_date_css_class(Time.zone.today + 2.months)).to eq 'Yes'
    end

    it 'returns "Maybe" if expire_date less than a month away' do
      expect(expire_date_css_class(Time.zone.today + 2.days)).to eq 'Maybe'
    end

    it 'returns "No" if expire_date has passed' do
      expect(expire_date_css_class(Time.zone.today - 2.days)).to eq 'No'
    end
  end

end
