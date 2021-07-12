namespace :shf do
  namespace :one_time do

    desc 'Set payment_processor for legacy payments to "HIPS"'

    task_name = 'init_payment_processor'

    task task_name.to_sym => :environment do

      ActivityLogger.open(LogfileNamer.name_for(task_name), 'OneTimeRakeTask', task_name) do |log|

        log.info("Setting payment_processor to HIPS for legacy payments.")

        Payment.all.each do |payment|
          payment.update_column(:payment_processor, 'HIPS')
        end

        log.info("Set payment processor for #{Payment.count} payments.")

      end

    end

  end
end
