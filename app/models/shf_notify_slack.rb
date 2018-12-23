#!/usr/bin/ruby

require 'slack-notifier'


#--------------------------
#
# @class SHFNotifySlack
#
# @desc Responsibility: Send a notification out to Slack from some SHF task or code.
#                       Standardizes the format, emjois, and colors.
#                       Is a simple, standardized wrapper around SlackNotifier.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2018-12-10
#
# @file shf_notify_slack.rb
#
#--------------------------
class SHFNotifySlack

  SLACK_COLOR_LTBLUE  = '#439FE0'
  SLACK_SUCCESS_COLOR = "good"
  SLACK_FAIL_COLOR    = "danger"
  SLACK_SUCCESS_EMOJI = ':white_check_mark:'
  SLACK_FAIL_EMOJI    = ':x:'
  SUCCESS_TEXT        = 'Successful'
  FAILURE_TEXT        = 'Failure!'

  FOOTER_PREFIX = 'SHF'


  # Surround a block of code with this method.
  # If an error is raised from code_run, a failure_notification is sent
  #  and the original error is raised.
  #
  # If the code block runs successfully, a successful_notification is sent.
  #
  # See the RSpec specification for examples.
  #
  def self.notify_after(notification_source, success_text: SUCCESS_TEXT,
      failure_text: FAILURE_TEXT,
      success_emoji: SLACK_SUCCESS_EMOJI,
      failure_emoji: SLACK_FAIL_EMOJI)

    yield

    begin
      self.success_notification(notification_source, text: success_text, emoji: success_emoji)
    rescue => err
      raise err
    end

  rescue => some_error
    self.failure_notification(notification_source, text: "#{failure_text} #{some_error}", emoji: failure_emoji)
    raise some_error
  end


  def self.success_notification(notification_source, text: SUCCESS_TEXT,
      emoji: SLACK_SUCCESS_EMOJI)

    self.notification(notification_source, text,
                      emoji: emoji,
                      color: SLACK_SUCCESS_COLOR)
  end


  def self.failure_notification(notification_source, text: FAILURE_TEXT,
      emoji: SLACK_FAIL_EMOJI)

    self.notification(notification_source, text,
                      emoji: emoji,
                      color: SLACK_FAIL_COLOR)
  end


  # Sends a notification to Slack using a Slack::Notifier.
  # Adds timestamps to the text and uses the emoji.
  #
  # @param notification_source [String] - shows in the footer
  #                   so we know the source of the message. Cannot be blank
  # @param text [String] - main text for the notification
  # @param emoji [String] (optional) - emoji name to use; must be in the
  #                   Slack format  ":emojiname:"
  #                   see https://www.webpagefx.com/tools/emoji-cheat-sheet/
  def self.notification(notification_source, text,
      emoji: SLACK_SUCCESS_EMOJI,
      color: SLACK_COLOR_LTBLUE)

    raise ArgumentError if notification_source.blank?


    slack_notifier = Slack::Notifier.new(ENV['SHF_SLACK_WEBHOOKURL'],
                                         channel:  ENV['SHF_SLACK_CHANNEL'],
                                         username: ENV['SHF_SLACK_USERNAME'])

    details = self.make_details(notification_source, text, color: color)

    slack_notifier.post attachments: [details], icon_emoji: emoji

  end


  # @param source [String] - a string describing the source of the notification
  #              Ex: the task name if this is a Rails or Rake task
  #              Ex: a method or class name
  #              Ex: a short descriptive text
  def self.make_details(source, text = '', color: SLACK_COLOR_LTBLUE)

    raise ArgumentError if source.blank?

    success_timestamp = DateTime.now.utc
    ts_text           = timestamped_text(text, success_timestamp)

    {
        'fallback': ts_text,
        'color':    color,
        'title':    ts_text,
        'footer':   footer_text(source),
        'ts':       success_timestamp.to_i
    }
  end


  def self.timestamped_text(t_text = '', timestamp = DateTime.now.utc)
    "#{t_text} #{timestamp}"
  end


  def self.footer_text(f_text = '')
    "#{FOOTER_PREFIX}: #{f_text}"
  end

end # SHFNotifySlack

