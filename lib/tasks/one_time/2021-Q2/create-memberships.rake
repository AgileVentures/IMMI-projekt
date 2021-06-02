namespace :shf do
  namespace :one_time do

    # Create a membership (object) for all current and former members, based on membership_fee payments.
    #   If a membership (for a payment) already exists, do not create a new one. (This can be run
    #   multiple times without loss of information.)
    # This should be run when we are implementing the Membership and related models on the production system.
    desc 'Create Memberships based on Payments.'
    task create_memberships: :environment do |this_task|

      full_task_name = this_task.to_s
      task_name = full_task_name.split(':').last # the task name without the namespace(s)

      log_msg_starter = 'Creating Memberships from the latest Payments'

      ActivityLogger.open(LogfileNamer.name_for("SHF-one-time-task-#{task_name}"), 'OneTimeRakeTask', task_name) do |log|
        log.info("#{log_msg_starter}.")

        begin
          current_members = User.where(member: true)

          # former members are those that are not members but have made successful membership payments
          former_members = User.joins(:payments).where(member: false)
                               .where("payments.status = '#{Payment::SUCCESSFUL}' AND payments.payment_type = '#{Payment::PAYMENT_TYPE_MEMBER}'")

          current_members_create_memberships(current_members, log)

          # Make sure all membership statuses are up to date for the current members.
          #   Miight have some that are now in the grace period, etc.
          update_current_members_statuses

          former_members_create_memberships(former_members, log)

          # Users without a membership_status set is not a member
          User.where(membership_status: nil).update_all(membership_status: 'not_a_member')

        rescue => error
          error_message = ">> ERROR! Could not create Memberships: #{error}"
          log.error error_message
          raise error, error_message
        end

        log_num_of_all_statuses(log)
        log.info("\n#{log_msg_starter} successful and complete. #{Membership.count} memberships exist.")
      end
    end
  end
end


def current_members_create_memberships(current_members = [], log)
  log.info(" Creating memberships for current members (only if a membership doesn't already exist)...")
  current_members.each do |current_member|

    # If they are a member, we make them a current member.  They may or may not have met all of the
    # current requirements for membership. IOW, what they were required to do may or may not include
    # what we currently require. Ex: they may or may not have needed to accept the guidelines.
    most_recent_membership_payment = current_member.most_recent_payment
    unless_membership_exists(current_member, most_recent_membership_payment, log) do |member, payment, this_log|
      start_membership(member, payment, this_log)
    end
  end
  log.info(" ... finished checking current members.")
end


def update_current_members_statuses
  User.current_member.each do |user|
    # FIXME should emails be sent?
    MembershipStatusUpdater.instance.update_membership_status(user) unless user.admin?
  end
end


def start_membership(member, payment, log)
  member.start_membership!(date: payment.start_date, send_email: false)
  member.update!(membership_status: :current_member)
  log.info(member.membership_changed_info)
end


def former_members_create_memberships(former_members = [], log)
  log.info(" Creating memberships for former members (only if a membership doesn't already exist)...")
  former_members.each do |former_member|
    unless_membership_exists(former_member, former_member.most_recent_payment, log) do |member, payment, _this_log|
      create_membership_from_payment(member, payment)
      member.update(membership_status: :former_member)
    end
  end
  log.info(" ... finished checking former members.")
end


def unless_membership_exists(user, membership_payment, log)
  if user.memberships.empty?
    yield user, membership_payment, log
  else
    # do not create a membership if one already exists with this first_day
    membership_exists_starting = Membership.where(user: user,
                                                  first_day: membership_payment.start_date,
                                                  last_day: membership_payment.expire_date)
    unless membership_exists_starting
      yield user, membership_payment, log
    end
  end
end


def create_membership_from_payment(user, membership_payment)
  Membership.create!(user: user,
                     member_number: user.membership_number,
                     first_day: membership_payment.start_date,
                     last_day: membership_payment.expire_date,
                     notes: membership_payment.notes)
end


def log_num_of_all_statuses(log)
  log.info("#{User.count} total Users in the db")
  total_in_statuses = 0
  status_counts = []
  User.membership_statuses.each do |stat|
    num = User.send(stat).count
    log.info " #{num} users with membership status #{stat}"
    status_counts << num
    total_in_statuses += num
  end
  log.info(" ------------------------------------------------------")
  log.info(" #{status_counts.join(' + ')} = #{total_in_statuses}  (to verify the numbers)")
end
