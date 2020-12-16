require 'rails_helper'

require 'shared_context/users'


RSpec.describe AdminOnly::GetMembersNeedingPackets do

  # TODO: Can any of the queries or objects be mocked?
  describe '.members with no welcome packet sent' do

    include_context 'create users'

    # Payment start date just needs to be a few days before today so it's clear
    #   that the membership term has started but hasn't ended yet
    let(:payment_start_date) { Date.today - 10 }

    def create_member_with_payments(payment_start, first_name = '')
      mem_no_pkt = create_member_with_payments_on([payment_start])
      mem_no_pkt.update(first_name: first_name)
      mem_no_pkt
    end

    let(:applicant) do
      appl = applicant_approved_no_payments # from shared context
      appl.update(first_name: 'Applicant') # email_1
      appl
    end

    let(:member_no_pkt_1) { create_member_with_payments(payment_start_date, 'No Pkt 1') }
    let(:member_no_pkt_2) { create_member_with_payments(payment_start_date + 1, 'No Pkt 2') }
    let(:member_expired) { create_member_with_payments(payment_start_date - 400, 'Expired') }
    let(:member_pkt_sent) do
      mem_pkt_sent =  create_member_with_payments(payment_start_date, 'Pkt Sent')
      mem_pkt_sent.update(date_membership_packet_sent: payment_start_date)
      mem_pkt_sent
    end

    let(:companies_with_members) do
      co1 = member_no_pkt_1.shf_application.companies.first
      co2 = member_no_pkt_2.shf_application.companies.first
      co3_pkt_sent = member_pkt_sent.shf_application.companies.first
      [co1, co2, co3_pkt_sent]
    end

    before(:each) do
      # make this be true no matter what.  TODO: does actually this save any queries or anything?
      allow(UserChecklistManager).to receive(:completed_membership_guidelines_if_reqd?)
                                       .and_return(true)
    end

    it 'calls Company.current_with_current_members to get the list of current members in current (licensed) Companies' do
      expect(Company).to receive(:current_with_current_members).and_return([])
      described_class.members_with_no_membership_packet
    end

    it 'has no duplicates' do
      allow(Company).to receive(:current_with_current_members)
                          .and_return(companies_with_members)
      result = described_class.members_with_no_membership_packet

      expected_member_no_pkt_1 = User.find_by(first_name: 'No Pkt 1')
      expectedmember_no_pkt_2 = User.find_by(first_name: 'No Pkt 2')
      expect(result.to_a).to match_array([expected_member_no_pkt_1,
                                          expectedmember_no_pkt_2])
    end


    it 'no member has a membership packet sent' do
      allow(Company).to receive(:current_with_current_members)
                          .and_return(companies_with_members)
      result = described_class.members_with_no_membership_packet

      expect(result.to_a.select(&:membership_packet_sent?)).to be_empty
    end

    it 'is sorted by the membership payment term start date' do
      allow(Company).to receive(:current_with_current_members)
                          .and_return(companies_with_members)
      result = described_class.members_with_no_membership_packet

      expect(result.first).to eq(User.find_by(first_name: 'No Pkt 1'))
      expect(result.last).to eq(User.find_by(first_name: 'No Pkt 2'))
    end
  end
end
