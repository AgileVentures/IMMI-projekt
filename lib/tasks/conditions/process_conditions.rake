require 'active_support/logger'

namespace :shf do

  desc 'process conditions'
  task :process_conditions => [:environment] do

    LOG = 'log/conditions'

    ActivityLogger.open(LOG, 'SHF_TASK', 'Conditions') do |log|

      begin
        class_name = nil
        klass = nil

        Condition.order(:class_name).each do |condition|

          unless condition.class_name == class_name
            klass = condition.class_name.constantize
            class_name = condition.class_name
          end

          log.record('info', "#{class_name}: #{condition.name} ...")

          if klass
            klass.condition_response(condition, log)
          else
            raise 'klass not assigned in task shf:process_conditions'
          end

        rescue StandardError => e
          log.record('error', "Exception: #{e.inspect}")
          raise
        end
      end
    end
  end
end
