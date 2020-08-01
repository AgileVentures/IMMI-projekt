#!/usr/bin/ruby


#--------------------------
#
# @class AlertLogger
#
# @desc Responsibility: write Alert information to a log
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-04-18
#
# @file AlertLogger
#
#--------------------------
class AlertLogger

  attr_accessor :log, :logged_class, :success_method, :failure_method


  # @param [Log] log - the log that will be written to
  # @param [EmailAlert] alert - the alert that is being logged about
  # @param [Symbol] success_info_method - the method that will be called when the alert needs
  #        to log a success; a callback
  # @param [Symbol] failure_info_method - the method that will be called when the alert needs
  #        to log a failure; a callback
  def initialize(log, alert, success_info_method: :success_str, failure_info_method: :failure_str)
    @log            = log
    @alert          = alert
    @success_method = success_info_method
    @failure_method = failure_info_method
  end


  def log_success(*log_args)
    info_str = alert_str_from_callback(@success_method, *log_args)
    log.info("#{msg_start} email sent #{info_str}.")
  end


  def log_failure(*log_args, error: '')
    info_str = alert_str_from_callback(@failure_method, *log_args)
    log.error("#{msg_start} email ATTEMPT FAILED #{info_str}. #{error} Also see for possible info #{ApplicationMailer.logfile_name} ")
  end


  private


  def msg_start
    @alert.class.name
  end


  def alert_str_from_callback(method, *alert_args)
    @alert.send(method, *alert_args)
  end
end
