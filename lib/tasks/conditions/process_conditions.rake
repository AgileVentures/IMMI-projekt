require 'active_support/logger'

namespace :shf do

  desc 'process conditions'
  task :process_conditions => [:environment] do

    LOG = 'log/conditions'

    ActivityLogger.open(LOG, 'SHF_TASK', 'Conditions') do |log|

      class_name = nil
      klass = nil

      Condition.order(:class_name).each do |condition|

        unless condition.class_name == class_name
          class_name = condition.class_name
          klass = class_name.constantize
        end

        log.record('info', "#{class_name} ...")

        SHFNotifySlack.notify_after(class_name) do

          if klass
            klass.condition_response(condition, log)
          else
            raise 'klass is nil in task shf:process_conditions'
          end
          
        end

      rescue StandardError => e
        log.record('error', "Exception: #{e.inspect}")
        raise
      end
    end
  end
end
