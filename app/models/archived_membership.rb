# Individual Membership that has been archived.  The information is saved only for auditing purposes,
#  but is not connected to any User or (archived) Payments so that privacy is maintained
#  (e.g. GDPR is followed).
#
class ArchivedMembership < ApplicationRecord

  NAME_EMAIL_ATTRIBS = %w(first_name last_name email)
  ID_USER_TIMESTAMP_ATTRIBS = %w(id created_at updated_at user_id)
  EXCLUDED_ATTRIBS_FOR_MATCHING = ID_USER_TIMESTAMP_ATTRIBS + NAME_EMAIL_ATTRIBS.map{|attrib| "belonged_to_#{attrib}"}

  # ================================================================================================



  # Create a new ArchivedMembership only if one does not already exist for the membership
  # @return [nil | ArchiveMembership] - return nil if nothing is created,
  #   else return the created ArchiveMembership
  def self.create_from(membership)
    return nil if membership.nil?

    return nil if archived_membership_exists_for?(membership)

    attribs = {}
    attribs_to_match.each { |attrib| attribs[attrib] = membership[attrib] }
    attribs[:belonged_to_first_name] = membership.user.first_name
    attribs[:belonged_to_last_name] = membership.user.last_name
    attribs[:belonged_to_email] = membership.user.email

    create!(attribs)
  end

  # @return [True|False] - true if an ArchivedMembership exists where these match the membership:
  #   user first name
  #   user last name
  #   user email
  #   all of the remaining membership attributes, excluding created_at and updated_at
  #   Note that in the future it might be helpful to find a match also excluding the email
  #    because the email might have changed, and either the searcher doesn't know what the
  #    email was or uses the current email, which might be different from what it was.
  #
  def self.archived_membership_exists_for?(membership)
    archived_for_name_email = matching_names_email(membership.user.first_name,
                                                   membership.user.last_name,
                                                   membership.user.email)
    return false if archived_for_name_email.empty?

    matching_other_attribs =  archived_for_name_email.select{|archived_membership| archived_membership.these_attribs_match_membership(membership,attribs_to_match) }
    !matching_other_attribs.empty?
  end


  def self.matching_names_email(first_name, last_name, email)
    where(belonged_to_first_name: first_name)
       .where(belonged_to_last_name: last_name)
       .where(belonged_to_email: email)
  end


  def self.attribs_to_match
    (ArchivedMembership.new.attributes.keys - EXCLUDED_ATTRIBS_FOR_MATCHING).map(&:to_sym)
  end

  # ------------------------------------------------------------------------------------------------


  def these_attribs_match_membership(membership, these_attribs = [])
    return false if these_attribs.blank?

    these_attribs.inject(true){|matching_so_far, attrib| matching_so_far && self[attrib] == membership[attrib] }
  end
end
