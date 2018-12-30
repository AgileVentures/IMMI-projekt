require 'singleton'

#--------------------------
#
# @class AbstractUpdater
#
# @desc Abstracts the behavior and information common to the Updaters.
#
#       Updaters check to see if requirements are met, and then do something
#         ("do events and update info")
#       If requirements are not met, the Updater checks to see
#           if it is ok to 'revoke the update with events and info'.
#       Often there is an opposite of the 'update the info' action;
#           this is the 'revoke the update' action.
#
#       If the requirements are met, do events and update info ('update_action').
#       Else  (the requirements are not met)
#          if it is ok to revoke the update with events and info (''),
#             do whatever is needed to revoke the update with events and
#               info ('revoke_update_action')
#
#       Typically an Updater will work with another class (service/object/interface)
#       or classes that has (have) the responsibility for checking the requirements.
#
#       Updaters are singletons
#
#
#       Each subclass MUST define the following methods:
#         'self.update_requirements_checker'  returns the AbstractRequirements class
#             that is responsible for checking that the
#             requirements are met/it's ok to "do events and update info"
#         'self.revoke_requirements_checker'  returns the AbstractRequirements class
#             that is responsible for checking that the
#             requirements are met/it's ok to 'revoke the update with events and info'
#
#         'update_action(args)'  does whatever is needed to be done
#             when the requirements are met
#             ex:  send email, update attributes, etc.
#
#         'revoke_update_action(args = {})'  does whatever is needed to be done
#             to "revoke (undo)" the update action
#             ex:  send email, update attributes, etc.
#             It's quite possible that there is nothing to be done,
#               and so this method might just be empty (= do nothing)
#             It is not defined in this abstract class so that
#               an error is raised if it is not defined, thus ensuring
#               that the author(s) of subclasses explicitly consider
#               what does or does not need to happen.
#
#       (If a subclass does not need that methods, it's fine to not define it.)
#
#
#       It is the responsibility of each subclass to parse the arguments as needed.
#       They are handled as a *Hash* to allow for variation in the number and type(s) of
#       arguments that are needed by subclasses.
#
#
#       It is currently also used to abstract out some logging just for
#       demonstration purposes during the spike/exploration.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/22/17
# @file abstract_updater.rb
#
#
#--------------------------


class AbstractUpdater

  include Singleton


  # This is just a reminder that subclasses must implement this method.
  # It is purposefully not defined here so that an error will be raised
  # if it is not defined in a subclass.
  #
  # AbstractRequirements class to use for checking that the requirements
  # are met for doing the update_action
  #
  # def self.update_requirements_checker
  #
  # end


  # This is just a reminder that subclasses must implement this method.
  # It is purposefully not defined here so that an error will be raised
  # if it is not defined in a subclass.
  #
  # AbstractRequirements class to use for checking that the requirements
  # are met for doing the revoke_update_action
  #
  # def self.revoke_requirements_checker
  #
  # end


  # It is the responsibility of each subclass to parse the arguments as needed.
  # They are an array here to allow for variation in the number and type(s) of
  # arguments that are needed by subclasses.
  #
  def check_requirements_and_act(args = {})

    updater_class = self.class

    ActivityLogger.open(log_filename, updater_class.to_s, "#{__method__}", false) do |log|
      log.record(:info, "checking check_requirements_and_act for #{args.inspect}")
    end

    if updater_class.update_requirements_checker.satisfied? args
      update_action args
    else
      revoke_update_action(args) if updater_class.revoke_requirements_checker.satisfied? args
    end

  end


  # This is just a reminder that subclasses must implement this method.
  # It is purposefully not defined here so that an error will be raised
  # if it is not defined in a subclass.
  #
  # Requirements were satisified, so do the update.
  #  Set states (values) and do any behaviors (events) needed.
  #
  # def update_action(args = {})
  #
  # end


  # This is just a reminder that subclasses must implement this method.
  # It is purposefully not defined here so that an error will be raised
  # if it is not defined in a subclass.
  #
  # Requirements were not satisfied, so undo/revoke the update
  # The default is to do nothing.  Subclasses may need to explicitly
  # set some state(s) or trigger some events
  #   ex:  May need to 'revoke membership' if membershipship requirements are no longer met.
  #        This could mean setting some states (values) and sending out an email.
  #
  # def revoke_update_action(args = {})
  #
  # end


  def log_filename
    File.join(Rails.configuration.paths['log'].absolute_current, "#{Rails.env}_#{self.class.name}.log")
  end


end # AbstractUpdater

