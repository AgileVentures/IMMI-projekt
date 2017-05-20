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
  # [SHF_TASK] [Load Kommuns] [info] 290 Regions created.
  # [SHF_TASK] [Load Kommuns] [info] Finished at 2017-05-20 17:25:39 -0400.
  # [SHF_TASK] [Load Kommuns] [info] Duration: 0.67 seconds.
  #
  # Here, the facility is an SHF task file, the activity is loading Kommuns
  # into the DB, and the messages are all of INFO severity.
  #
  # Usage:
  # 1) call log = ActivityLogger.new(logfile, facility, activity)
  # 2) for each logged message during the activity,
  #    call log.record(severity, message),
  #    where severity is one of 'debug', 'info, 'warn', 'error', 'fatal', 'unknown'
  # 3) when the activity is complete,
  #    call log.close

  def initialize(filename, facility, activity, show=true)
    @filename = filename
    @facility = facility
    @activity = activity
    @facility_and_action = "[#{facility}] [#{activity}] "
    @show = show
    @start_time = Time.now

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
    finish_time = Time.now
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
