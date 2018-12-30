require 'rails_helper'


# We use the User class since it includes the PaymentUtility class

RSpec.describe User, type: :model do

  let(:MembershipFee) { Payment::PAYMENT_TYPE_MEMBER }
  let(:BrandingFee) { Payment::PAYMENT_TYPE_BRANDING }

  let(:jul_1) { Time.zone.local(2018,  7, 1) }

  let(:dec_1) { Time.zone.local(2018, 12, 1) }
  let(:dec_2) { Time.zone.local(2018, 12, 2) }
  let(:dec_3) { Time.zone.local(2018, 12, 3) }

  let(:nov_30_next_year) { Time.zone.local(2019, 11, 30) }

  let(:lastyear_dec_2)  { Time.zone.local(2017, 12, 2) }

  let(:success) { Payment.order_to_payment_status('successful') }


  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.next_payment_dates' do

    context 'entity not found' do

      describe 'returns empty array' do
        context 'membership fee' do
         pending # expect(described_class.next_payment_dates(100, Payment::PAYMENT_TYPE_MEMBER)).to eq []
        end
        context 'branding fee' do
          pending # expect(described_class.next_payment_dates(100, Payment::PAYMENT_TYPE_BRANDING)).to eq []
        end
      end
    end

    context 'entity found' do

      context 'no payments' do
        let(:user) { create(:user) }
        let(:company) { create(:company) }

        describe 'membership fee' do
         pending
         # it 'start date = today, expire = 1 year + 1 day of start date' do
         #   expect(described_class.next_payment_dates(user.id, Payment::PAYMENT_TYPE_MEMBER)).to eq [ dec_1, nov_30_next_year]
         #   expect(described_class.next_payment_dates(company.id, Payment::PAYMENT_TYPE_MEMBER)).to eq [dec_1, nov_30_next_year]
         # end
        end

        #it 'branding fee' do
          #expect(described_class.next_payment_dates(user.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [dec_1, nov_30_next_year]
          #expect(described_class.next_payment_dates(company.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [dec_1, nov_30_next_year]
        #end
      end

      context 'found payments' do

        context 'User' do
          context 'does not have an approved membership app' do
            context 'membership fee' do
              pending 'test for each type of entity'
            end
            describe 'branding fee' do
             pending 'test for each type of entity'
            end
          end

          context 'does have an approved membership app' do
            context 'membership fee' do
              pending 'test for each type of entity that can have a membership app'
            end
            context 'branding fee' do
              pending 'test for each type of entity'
            end
          end
        end


        context 'only considers the successful payments' do
          pending
        end
      end
    end
  end


  describe '.expire_date_for_start_date' do

    it 'is 1 calendar year minus 1 day' do
      computed = described_class.expire_date_for_start_date(Time.zone.local(2018, 1, 1))
      expect(computed).to eq Time.zone.local(2018, 12, 31)
    end

    it 'leap year' do
      computed = described_class.expire_date_for_start_date(Time.zone.local(2020, 2, 1))
      expect(computed).to eq Time.zone.local(2021, 1, 31)
    end

  end

end
