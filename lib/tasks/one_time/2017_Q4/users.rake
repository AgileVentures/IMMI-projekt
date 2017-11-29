# PREREQUISITE MIGRATIONS:
# 20171025191957_add_member_to_users

# PREREQUISITE RAKE TASKS:
# None

namespace :shf do
  namespace :users do

    desc "Assign member status for appropriate users"
    task set_member_status: :environment do

      LOG_FILE = 'log/users_member_status'

      ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Set member status') do |log|

        members = User.joins(:membership_applications)
                      .where("membership_applications.state = 'accepted'")
                      .distinct

        members_set = 0

        log.record('info', "Checking status for #{members.count} members.")

        members.each do |member|
          next if member.member

          member.member = true
          member.save
          members_set += 1
        end

        log.record('info', "Set status for #{members_set} members.")
      end
    end
  end
end
