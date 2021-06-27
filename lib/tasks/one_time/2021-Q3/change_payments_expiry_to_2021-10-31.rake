require 'active_support/logger'

namespace :shf do

  namespace :one_time do

    def payments_to_change(time_range)
      Payment.completed.where(expire_date: time_range).distinct.order(:expire_date)
    end


    def change_payment_expire_day_and_notes(payment, new_expire_date, task_name)
      changed_by_task_str = "Changed by rake task #{task_name} on #{Time.now} : "
      last_day_changed_str = "Payment expire_date changed to #{new_expire_date.iso8601}. Original expire_date was #{payment.expire_date.iso8601}."

      new_note = payment.notes.to_s + ' | ' +
         changed_by_task_str + last_day_changed_str
      payment.update!(expire_date: new_expire_date)
      payment.update!(notes: new_note)
      payment
    end


    desc "change Payments expire_date to 2021-Oct-31 for members and companies with expire_date 2021-01-01 to 2021-10-30"
    task change_payments_expire_date_to_2021_10_31: [:environment] do |this_task|
      task_name_end = this_task.to_s.split(':').last # the task name without the namespace(s)

      NEW_EXPIRE_DATE = Date.new(2021, 10, 31)
      MIN_EXPIRE_DATE = Date.new(2021, 01, 01)
      MAX_EXPIRE_DATE = Date.new(2021, 10, 30)

      LOG_MSG_STARTER = "Change Membership last_days and Company branding license expire_dates to #{NEW_EXPIRE_DATE.iso8601}"

      time_range = MIN_EXPIRE_DATE..MAX_EXPIRE_DATE

      ActivityLogger.open(LogfileNamer.name_for("SHF-one-time-task-#{task_name_end}"), 'OneTimeRakeTask', task_name_end) do |log|
        log.info("#{LOG_MSG_STARTER}.")
        begin
          num_payments_changed = 0
          payments_in_range  = payments_to_change(time_range)
          payments_in_range.each do |payment|
            change_payment_expire_day_and_notes(payment, NEW_EXPIRE_DATE, this_task.to_s)
            MembershipStatusUpdater.instance.payment_made(payment, send_email: false)
            num_payments_changed += 1
          end
          log.info(" #{num_payments_changed} Payments updated")

        rescue => error
          error_message = ">> ERROR! Could not change membership last_day/expire_date: #{error}"
          log.error error_message
          raise error, error_message
        end

        log.info("\n#{LOG_MSG_STARTER} successful and complete.")
      end
    end
  end

end
