require 'rails_helper'

require 'shared_context/users'


RSpec.describe AdminOnly::GetMembersNeedingPackets do

  describe ".members with no welcome packet sent (they  must belong to a currently licensed Company)" do

    include_context 'create users'

    let(:members_with_no_packet_sent) do
      # make this be true no matter what
      allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?)
                                         .and_return(true)

      # Payment start date just needs to be a few days before today so it's clear that the membership term has started but hasn't ended yet
      payment_start_date = Date.today - 10

      # we don't need to refer to these by name, so we can just create them all here
      applicant = applicant_approved_no_payments # from shared context
      applicant.update(first_name: 'Applicant') # email_1

      member_no_pkt_1 = create_member_with_payments_on([payment_start_date])
      member_no_pkt_1.update(first_name: 'No Pkt 1')

      member_no_pkt_2 = create_member_with_payments_on([payment_start_date + 1])
      member_no_pkt_2.update(first_name: 'No Pkt 2')

      member_pkt_sent = create_member_with_payments_on([payment_start_date])
      member_pkt_sent.update(first_name: 'Pkt Sent')
      member_pkt_sent.update(date_membership_packet_sent: payment_start_date)

      # membership_expired = member_expired # from shared context
      membership_expired = create_member_with_payments_on([payment_start_date - 400])
      membership_expired.update(first_name: 'Expired')

      described_class.members_with_no_membership_packet
    end

    it "every one must be a member (meet all requirements)" do
      expect(members_with_no_packet_sent.all? { |member| RequirementsForMembership.requirements_met?({user: member})}).to be_truthy
    end

    it "every one must belong to a currently licensed company" do
      expect(members_with_no_packet_sent.all? { |member| member.companies.all? { |co| co.branding_license? } }).to be_truthy
    end

    it 'has expected results' do
      expect(members_with_no_packet_sent.size).to eq 2
      member_no_pkt_1 = User.find_by(first_name: 'No Pkt 1')
      member_no_pkt_2 = User.find_by(first_name: 'No Pkt 2')
      expect(members_with_no_packet_sent.to_a).to match_array([member_no_pkt_1, member_no_pkt_2])
    end

    it 'is sorted by the membership payment term start date' do
      expect(members_with_no_packet_sent.first).to eq(User.find_by(first_name: 'No Pkt 1'))
      expect(members_with_no_packet_sent.last).to eq(User.find_by(first_name: 'No Pkt 2'))
    end
  end


end
