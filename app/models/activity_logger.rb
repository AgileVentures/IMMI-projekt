class ActivityLogger

  # This supports simple logging of activity, such as loading data into the
  # the DB with a rake task.
  # This also allows for output to STDOUT of logged messages.
  #
  # The format of the logged messages are:
  #
  # [facility] [activity] [severity] <message>
  # Example log contents:
  # [SHF_TASK] [Load Kommuns] [info] Started at 2017-05-20 17:25:39 -0400
  # [SHF_TASK] [Load Kommuns] [info] 290 Kommuns created.
  # [SHF_TASK] [Load Kommuns] [info] Finished at 2017-05-20 17:25:39 -0400.
  # [SHF_TASK] [Load Kommuns] [info] Duration: 0.67 seconds.
  #
  # Here, the facility is an SHF task, the activity is loading Kommuns
  # into the DB, and the messages are all of INFO severity.
  #
  # Usage:
  # 1) call ActivityLogger.open(logfile, facility, activity)
  #    -- assign the logger instance value to a local var (e.g., "log = ..."), OR
  #    -- pass a block which takes an argument (which is the logger instance)
  # 2) for each logged message during the activity,
  #    call log.record(severity, message), (log == logger instance)
  #    where severity is one of 'debug', 'info, 'warn', 'error', 'fatal', 'unknown'
  # 3) when the activity is complete,
  #    -- the log file will be closed automatically if opened with a block, OR
  #    -- call log.close

  def self.open(filename, facility, activity, show=true)
    log = new(filename, facility, activity, show)

    if block_given?
      begin
        yield log
      ensure
        log.close
      end
    else
      log
    end
  end

  private def initialize(filename, facility, activity, show)
    @filename = filename
    @facility = facility
    @activity = activity
    @facility_and_action = "[#{facility}] [#{activity}] "
    @show = show
    @start_time = Time.zone.now

    @log = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(filename))

    record('info', "Started at #{@start_time}")
  end

  def record(log_level, message)
    raise 'invalid log severity level' unless
      ActiveSupport::Logger::Severity.constants.include?(log_level.upcase.to_sym)

    @log.tagged(@facility, @activity, log_level) do
      @log.send(log_level, message)
    end

    puts @facility_and_action + "[#{log_level}] " + message if @show
  end

  def close(duration: true)
    finish_time = Time.zone.now
    record('info', "Finished at #{finish_time}.")
    record('info',
      "Duration: #{(finish_time - @start_time).round(2)} seconds.\n") if duration
    @log.close
    logged_to if @show
  end

  def logged_to
    puts @facility_and_action + '[info] ' + "Information was logged to: #{@filename}"
  end

end
