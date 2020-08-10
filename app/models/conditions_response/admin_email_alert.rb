# Abstract parent class for all alerts that send out emails to admins
#
# Responsibility: sets the information needed so that the parent class(es) can
#  process the condition for an email sent to Admins
#
#  SUBCLASSES MUST IMPLEMENT SPECIFIC METHODS.
#  They must be implemented to satisfy the interface for this abstract class.
#  Any method that a subclass must implement will raise a NoMethod error
#  here in this class unless a subclass implements it.
#
#
class AdminEmailAlert < EmailAlert

  # add items to the list that is then put into the content of the alert sent
  attr_accessor :items_list



  # Go through all items and add any to the list of items that we need to.
  # Then send email to all Admins with that list of items as information.
  #
  # This is a different use of 'items_to_check': these are used as the _content_
  # of the alert sent, instead of possible recipients.
  def process_entities(items_to_check, log)
    @items_list = []

    # Get all of the items that will be put into the contents of the alert sent.
    @items_list = gather_content_items(items_to_check)

    # send email to admins with the items of interest
    if !items_list.empty? && send_alert_this_day?(@timing, @config, nil)
      recipients.each do |admin|
        send_email(admin, log, [items_list])
      end
    end
  end


  # default is all users that are not admins.  Subclasses can override this as needed
  def items_to_check
    User.not_admins
  end

  alias_method :entities_to_check, :items_to_check


  # @return [Array] - list of all items that will be included in the body of the
  #  alert sent.
  #  Default is to go through each item and add it to the list
  #   iff add_item_to_list?? is true
  #
  # Subclasses can override/redefine this to return whatever list of items is appropriate
  #
  def gather_content_items(items)
    items.select { |item| add_item_to_list?(item) }
  end


  # This loops through the items, but doesn't send email to them.
  # It loops through the items to gather information and then sends email to admins.
  #
  # def take_action(item, _log)
  #   (items_list.append(item)) if add_item_to_list?(item)
  # end


  # Subclasses can define this
  def add_item_to_list?(_item)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end


  # Default is to send to all admins
  # TODO would it be better to only send it to the SHF membership email?
  #   Ex: temp_admin_membership = User.new(first_name: 'Membership', last_name: 'Administrator',
  #                                      password: "does not matter for this",  <-- we don't really need this pwe
  #                                      email: ENV['SHF_MEMBERSHIP_EMAIL'])
  #   then set the recipients list to just that temporarily build (not saved to db) User
  #
  def recipients
    User.admins
  end


  # send an alert only if we send one every day OR if it is the right day of the month
  def send_alert_this_day?(timing, config, _entity)
    self.class.timing_matches_today?(timing, config)
  end


  def mailer_class
    AdminMailer
  end


  def mailer_args(admin)
    [admin, items_list]
  end


  def success_str(admin)
    user_info(admin)
  end


  def failure_str(admin)
    user_info(admin)
  end


  # ------------------------


  private


  def user_info(admin)
    admin.nil? ? "admin is nil" : "to id: #{admin.id} email: #{admin.email}"
  end

end
