require 'rails_helper'

RSpec.describe ArchivedMembership, type: :model do
  let(:given_membership) { build(:membership) }
  let(:arch_matches_all) do
    create(:archived_membership,
           belonged_to_first_name: given_membership.user.first_name,
           belonged_to_last_name: given_membership.user.last_name,
           belonged_to_email: given_membership.user.email,
           first_day: given_membership.first_day,
           last_day: given_membership.last_day,
           member_number: given_membership.member_number,
           notes: given_membership.notes)
  end


  describe '.create_from' do

    context 'an ArchiveMembership for the given membership does not exist' do
      let(:created_archived_membership) { described_class.create_from(given_membership) }

      it 'a new ArchiveMembership is created' do
        expect(created_archived_membership).not_to be_nil
      end

      it 'the first name, last name, and email are copied from the membership user' do
        expect(created_archived_membership.belonged_to_first_name).to eq(given_membership.user.first_name)
        expect(created_archived_membership.belonged_to_last_name).to eq(given_membership.user.last_name)
        expect(created_archived_membership.belonged_to_email).to eq(given_membership.user.email)
      end

      it 'the other attributes (not names, email, id, user id, timestamps) are copied from the membership' do
        # calls attribs_to_match once for this test, and once when the method is called
        expect(described_class).to receive(:attribs_to_match).at_least(1).times.and_call_original
        described_class.attribs_to_match.each do |attrib|
          expect(created_archived_membership[attrib]).to eq given_membership[attrib]
        end

      end
    end

    context 'an ArchiveMembership for the given membership already exists' do
      it 'no ArchivedMembership is created ' do
        arch_matches_all # Creates this matching ArchiveMembership
        expect{ described_class.create_from(given_membership) }.not_to change(ArchivedMembership, :count)
      end
    end
  end


  describe '.archived_membership_exists_for?' do

    it 'false if no ArchivedMembership match the names and email' do
      allow(described_class).to receive(:matching_names_email).and_return([])
      expect(described_class.archived_membership_exists_for?(given_membership))
    end

    it 'true if there is at least 1 ArchivedMembership that matches names and email' do
      arch_matches_all = create(:archived_membership,
                                      first_day: given_membership.first_day,
                                      last_day: given_membership.last_day,
                                      member_number: given_membership.member_number,
                                      notes: given_membership.notes)
      arch_does_not_match_last_day = create(:archived_membership,
                                                  first_day: given_membership.first_day,
                                                  last_day: given_membership.last_day + 100,
                                                  member_number: given_membership.member_number,
                                                  notes: given_membership.notes)
      arch_does_not_match_notes = create(:archived_membership,
                                               first_day: given_membership.first_day,
                                               last_day: given_membership.last_day,
                                               member_number: given_membership.member_number,
                                               notes: 'these notes are different')

      allow(described_class).to receive(:matching_names_email)
                                  .and_return([arch_does_not_match_notes,
                                               arch_does_not_match_last_day,
                                               arch_matches_all])

      expect(described_class.archived_membership_exists_for?(given_membership)).to be_truthy
    end
  end


  describe '.matching_names_email' do

    it 'none if there is no ArchivedMembership that matches first_name AND last_name AND email for user membership' do
      expect(described_class.matching_names_email(given_membership.user.first_name,
                                                  given_membership.user.last_name,
                                                  given_membership.user.email)).to be_empty

      create(:archived_membership, belonged_to_first_name: given_membership.user.first_name,
             belonged_to_last_name: given_membership.user.last_name,
             belonged_to_email: 'this does not match')

      expect(described_class.matching_names_email(given_membership.user.first_name,
                                                  given_membership.user.last_name,
                                                  given_membership.user.email).count).to eq 0
    end

    it 'a list of all ArchivedMemberships matching the first name, last name, and email for the membership user' do
      matching_arch_mship = create(:archived_membership, belonged_to_first_name: given_membership.user.first_name,
             belonged_to_last_name: given_membership.user.last_name,
             belonged_to_email: given_membership.user.email)
      create(:archived_membership, belonged_to_first_name: given_membership.user.first_name,
             belonged_to_last_name: given_membership.user.last_name,
             belonged_to_email: 'this does not match')

      expect(described_class.matching_names_email(given_membership.user.first_name,
                                                  given_membership.user.last_name,
                                                  given_membership.user.email).to_a).to match_array([matching_arch_mship])
    end
  end


  describe 'these_attribs_match_membership' do
    it 'false if the given attributes is empty' do
      expect(subject.these_attribs_match_membership(create(:membership), nil))
      expect(subject.these_attribs_match_membership(create(:membership), []))
    end

    it 'true if all of the given attributes match the given membership' do
      matching_archived_membership = build(:archived_membership)
      attribs_to_match = %i(member_number notes)
      matching_archived_membership[:member_number] = given_membership[:member_number]
      matching_archived_membership[:notes] = given_membership[:notes]
      expect(matching_archived_membership.these_attribs_match_membership(given_membership,
                                                                         attribs_to_match))
        .to be_truthy
    end

    it 'false if one or more of the given attributes do not match the given membership' do
      matching_archived_membership = build(:archived_membership)
      attribs_to_match = %i(member_number notes)
      matching_archived_membership[:member_number] = given_membership[:member_number]
      matching_archived_membership[:notes] = 'these notes are different'
      expect(matching_archived_membership.these_attribs_match_membership(given_membership,
                                                                         attribs_to_match))
        .to be_falsey
    end
  end
end
