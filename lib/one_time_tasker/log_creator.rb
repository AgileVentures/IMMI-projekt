#--------------------------
#
# @module LogCreator
#
# @desc Responsibility: Creates the right kind of log: an ActivityLogger or
#   a NoLogger
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-06-04
#
# @file log_creator.rb
#
#--------------------------


module LogCreator


  # This will not log anything.
  # It will respond to the stubbed_methods below, but not do anything.
  class NoLogger

    # Create methods that don't do anything:
    no_op_methods = [:info, :warn, :error, :debug, :record, :open, :close]
    no_op_methods.each do |method_name|
      class_eval %{ def self.#{method_name}(*args);  end }, __FILE__, __LINE__
    end
  end


  def log
    @log ||= set_or_create_log
  end


  # Return the log to use.
  #
  # If the given log is nil, create one
  # else just return the given log
  #
  # If we created the log, set @this_created_the_log to true
  # so that, for example, we can explicitly close it.
  #
  def set_or_create_log(given_log = nil, logging: true,
                        log_facility_tag: '',
                        log_activity_tag: '')

    @this_created_the_log = false

    if given_log.nil?
      @log = make_log(logging, log_facility_tag: log_facility_tag,
               log_activity_tag: log_activity_tag)
    else
      @log = given_log
    end
  end


  def close_log_if_this_created_it(log)
    log.close if !log.nil? && self.this_created_the_log
  end


  def this_created_the_log
    @this_created_the_log ||= false
  end


  # ----------------------------------------------------------------------------


  private


  def make_log(logging = false, log_facility_tag: '', log_activity_tag: '')
    @this_created_the_log = true
    if logging
      klass = self.class == Class ? self : self.class

      logfile_name = ::LogfileNamer.name_for(klass)
      ::ActivityLogger.open(logfile_name,
                          log_facility_tag,
                          log_activity_tag)
    else
      NoLogger
    end
  end


end
