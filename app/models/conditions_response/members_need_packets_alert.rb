#--------------------------
#
# @class  MembersNeedPacketsAlert
#
# @desc Responsibility: Gather the items to show in the body of this alert and
#  define the mailer method and arguments for sending the alert
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund ( weedySeaDragon @ Github )
# @date 2020-08-05
#
#--------------------------

class MembersNeedPacketsAlert < AdminEmailAlert

  def gather_content_items(_starting_list)
    AdminOnly::GetMembersNeedingPackets.members_with_no_membership_packet
  end


  def mailer_args(admin)
    [admin, items_list]
  end


  def mailer_method
    :members_need_packets
  end

end
