require 'rails_helper'

RSpec.describe 'admin_mailer/members_need_packets.html.haml', type: :view do

  describe 'for each member that needs a packet, it shows:' do

    let(:member_paid_up1) do
      user = create(:member_with_membership_app, first_name: 'member', last_name: 'paid_up 1')
      user.payments << build(:membership_fee_payment)
      user
    end

    let(:member_2cos) do
      user = create(:member_with_membership_app, first_name: 'member', last_name: '2 companies')
      user.payments << build(:membership_fee_payment)
      co2 = create(:company, name: 'Second company', website: 'www.secondcompany.com')
      user.shf_application.companies << co2
      user
    end

    let!(:expected_members_needing_packets) { [member_paid_up1, member_2cos] }

    before(:each) do
      assign(:members_needing_packets, expected_members_needing_packets)
    end


    it 'full name and email, membership start date, business categories' do
      render
      expected_members_needing_packets.each do |expected_member|
        expect(rendered).to match(expected_member.full_name)
        expect(rendered).to match(expected_member.email)
        expect(rendered).to match(expected_member.membership_start_date.to_s)
        categories_list = expected_member.shf_application.business_categories.map(&:full_ancestry_name).join(', ')
        expect(rendered).to match(categories_list)
      end
    end


    describe 'each company the member belongs to:' do

      it 'name and website' do
        render
        expected_members_needing_packets.each do |expected_member|
          expected_member.companies.each do |member_company|
            expect(rendered).to match(member_company.name)
            expect(rendered).to match(member_company.website)
          end
        end
      end

      it 'show social media links if they exist' do
        co1 = member_paid_up1.companies.first
        co1.facebook_url = 'http://facebook.com/co1'
        co1.instagram_url = 'http://instagram.com/co1'
        co1.youtube_url = 'http://youtube.com/co1'
        co1.save

        render
        expect(rendered).to match('http://facebook.com/co1')
        expect(rendered).to match('http://instagram.com/co1')
        expect(rendered).to match('http://youtube.com/co1')
      end


      it 'postal address formatted for Sweden so it can be copied and pasted onto a label' do
        number_of_companies = expected_members_needing_packets.sum(0) { |m| m.companies.size }
        expect(view).to receive(:html_postal_format_entire_address)
                          .exactly(number_of_companies).times
        render
      end
    end
  end

end
