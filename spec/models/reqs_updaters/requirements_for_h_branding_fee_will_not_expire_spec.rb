require 'rails_helper'

RSpec.describe RequirementsForHBrandingFeeWillNotExpire, type: :model do

  let(:subject) { RequirementsForHBrandingFeeWillNotExpire }

  it '.opposite_class' do
    expect(subject.opposite_class).to eq RequirementsForHBrandingFeeWillExpire
  end


  describe '.has_expected_arguments?' do

    it 'args has expected :company key' do
      expect(subject.has_expected_arguments?({ company: 'some co' })).to be_truthy
    end

    it 'args does not have expected :company key' do
      expect(subject.has_expected_arguments?({ not_co: 'not some co' })).to be_falsey
    end

    it 'args is nil' do
      expect(subject.has_expected_arguments?(nil)).to be_falsey
    end
  end


  describe '.requirements_met?' do

    let(:jan_1) { Date.new(2019, 1, 1) }
    let(:jan_2) { Date.new(2019, 1, 2) }

    let(:june_19) { Date.new(2019, 6, 19) }

    let(:jan_5_2020) { Date.new(2020, 1, 5)}


    around(:each) do |example|
      Timecop.freeze(jan_2) do
        example.run
      end
    end


    context 'company does not have current members - is always true' do

      it 'is true ' do
        expect(subject.requirements_met?({ company: create(:company) })).to be_truthy
      end
    end


    context 'company has current members' do

      context 'branding fee not paid' do

        let(:paid_membership_only) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          member
        }

        let(:paid_member_co) { paid_membership_only.companies.first }

        it 'is true' do
          paid_membership_only
          expect(subject.requirements_met?({ company: paid_member_co })).to be_truthy
        end

      end # context 'branding fee not paid'


      context 'branding fee paid ' do

        context 'branding fee has not expired (is current)' do

          let(:paid_both_current) {
            member = create(:member_with_membership_app)
            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  jan_1,
                   expire_date: User.expire_date_for_start_date(jan_1))
            create(:h_branding_fee_payment,
                   :successful,
                   user:        member,
                   company:     member.companies.first,
                   start_date:  jan_1,
                   expire_date: Company.expire_date_for_start_date(jan_1))
            member
          }

          let(:paid_member_co) { paid_both_current.companies.first }


          it 'is false (will not be due)' do
            paid_both_current
            expect(subject.requirements_met?({ company: paid_member_co })).to be_falsey
          end

        end # context 'branding fee has not expired'


        context 'branding fee has expired' do

          let(:paid_both_but_hfee_expired) {
            member = create(:member_with_membership_app)
            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  jan_1,
                   expire_date: User.expire_date_for_start_date(jan_1))
            create(:h_branding_fee_payment,
                   :successful,
                   user:        member,
                   company:     member.companies.first,
                   start_date:  jan_2 - 500,
                   expire_date: User.expire_date_for_start_date(jan_2 - 500))
            member
          }

          let(:exp_fee_co) { paid_both_but_hfee_expired.companies.first }

          it 'is true' do
            paid_both_but_hfee_expired
            expect(subject.requirements_met?({ company: exp_fee_co })).to be_truthy
          end

        end # context 'branding fee has expired'

      end # 'branding fee paid'

    end #  context 'company has current members'


    context 'does not have current members' do

      let(:membership_expired) {
        member = create(:member_with_membership_app)
        create(:membership_fee_payment,
               :successful,
               user:        member,
               start_date:  jan_1,
               expire_date: User.expire_date_for_start_date(jan_1))
        create(:h_branding_fee_payment,
               :successful,
               user:        member,
               company:     member.companies.first,
               start_date:  june_19,
               expire_date: Company.expire_date_for_start_date(june_19))
        member
      }

      let(:co_memberships_expired) { membership_expired.companies.first }

      it 'is true' do
        Timecop.freeze(jan_5_2020) do
          membership_expired
          expect(subject.requirements_met?({ company: co_memberships_expired })).to be_truthy
        end

      end

    end


  end # describe '.requirements_met?'

end
