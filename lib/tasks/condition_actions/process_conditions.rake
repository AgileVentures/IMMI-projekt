require 'active_support/logger'

desc 'process conditions'
task :process_conditions => [:environment] do

  LOG = 'log/conditions'

  ActivityLogger.open(LOG, 'SHF_TASK', 'Conditions') do |log|

    class_name = nil

    Condition.order(:class_name).each do |condition|

      unless condition.class_name == class_name
        klass = condition.class_name.constantize
        class_name = condition.class_name
      end

      log.record('info', "Checking #{class_name}: #{condition.name} ...")

      klass.condition_response(condition, log)
    end
  end
end
