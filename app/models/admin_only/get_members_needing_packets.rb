module AdminOnly

  #--------------------------
  #
  # @class AdminOnly::GetMembersNeedingPackets
  #
  # @desc Responsibility: This gathers info: all members that need to have welcome packets sent.
  #     All current members
  #     that belong to at least 1 company that is in good standing (= complete info _and_ a current H-Mark license)
  #     and have not had a membership packet sent to them
  #
  #     The information provided by this clas  class can be used to send alerts
  #     or export information (e.g. in a .CSV file) or display info on a dashboard, etc.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   8/5/20
  #
  #--------------------------
  #
  class GetMembersNeedingPackets

    # This is an ugly series of queries to get the result.
    # But it is not run often.
    # (Could definitely look into optimizing this _if_ it becomes a performance issue.)
    #
    # @return [ActiveRecordRelation] - all members that belong to a Company in good standing (license fee is current)
    #   AND have not had a membership packet sent to them
    #
    def self.members_with_no_membership_packet
      current_licensed_cos_w_members = Company.current_with_current_members
      members = current_licensed_cos_w_members.map { |co| co.current_members }.flatten.uniq
      need_welcome_packet = members.select { |m| m.date_membership_packet_sent.nil? }
      need_welcome_packet.sort_by(&:membership_start_date)
    end

  end

end

