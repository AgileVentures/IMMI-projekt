class UserChecklistControllerError < StandardError
end
class MissingUserChecklistParameterError < UserChecklistControllerError
end
class UserChecklistNotFoundError < UserChecklistControllerError
end

#
# Note that there are NO new, create, edit, update, or destroy actions.
# A user cannot create a new checklist, nor can a user edit one or destroy one.
# Nor can an admin create a new one or edit one manually or destroy one
#

class UserChecklistsController < ApplicationController


  def index
    @user = User.find(params[:user_id])
    @user = current_user unless @user # default to the current_user if couldn't find the User

    # Verify that the current user is authorized to access the checklists for @user:
    authorize(@user, nil, policy_class: UserChecklistPolicy)

    # Get all the checklists for the user in the path. Ex: If the current user is an admin,
    # then we want to be sure to see the checklists for a specific user, not for the admin.
    found_lists = UserChecklist.where(user: @user) #.includes(:master_checklist)
    @user_checklists = found_lists.blank? ? [] : found_lists
  end


  def show
    set_user_checklist
    authorize_user_checklist
  end


  def show_progress
    @user = User.find(progress_params[:user_id])

    @user_checklist = UserChecklist.find(progress_params[:user_checklist_id])
    authorize_user_checklist
    @checklist_root = @user_checklist.root
    @overall_progress = @checklist_root.percent_complete
    check_membership_status_if_complete(@user_checklist.root, @overall_progress)

    if @overall_progress == 100
      # set the root to complete?
      render :membership_guidelines_completed # TODO revise the partial: generalize to work for any User checklist
    end
  end


  # (XHR request)
  # Toggle the date_completed for the checklist, then update all UserChecklists that
  # need to be changed because of it. (Ex: this may make a parent complete or incomplete.)
  #
  # Return data for this changed UserChecklist: the updated date_completed and percent complete.
  #
  def all_changed_by_completion_toggle
    handle_xhr_request do
      raise MissingUserChecklistParameterError, t('.missing-checklist-param-error') if params[:id].blank?

      user_checklist_id = params[:id]
      user_checklist = UserChecklist.find(user_checklist_id)
      raise ActiveRecord::RecordNotFound, t('.not_found', id: user_checklist_id) if user_checklist.nil?

      # toggle the date_completed and update any parents needed
      user_checklist.all_changed_by_completion_toggle

      check_membership_status_if_complete(user_checklist.root, user_checklist.root.percent_complete)

      { checklist_id: user_checklist.id,
        date_completed: user_checklist.date_completed,
        overall_percent_complete: user_checklist.percent_complete
      }
    end
  end


  # Set the given UserChecklist to completed (date_completed = Time.zone.now) and
  # set all of its descendants to completed, too.
  #
  # @return Hash - info about the user checklist item that was changed
  #      user_checklist_id: id of the user checklist item changed,
  #      date_completed: Date of when the user checklist item was completed (blank if not complete),
  #      overall_percent_complete: updated percent complete for the root checklist this one belongs to
  #
  def set_complete_including_kids
    handle_xhr_request do
      set_uc_and_kids_date_completed(params, Time.zone.now)
    end
  end


  # Set the given UserChecklist to uncompleted (date_completed = nil) and
  # set all of its descendants to uncompleted, too.
  #
  # @return Hash - info about the user checklist item that was changed
  #      user_checklist_id: id of the user checklist item changed,
  #      date_completed: blank,
  #      overall_percent_complete: updated percent complete for the root checklist this one belongs to
  #
  def set_uncomplete_including_kids
    handle_xhr_request do
      set_uc_and_kids_date_completed(params, nil)
    end
  end


  private


  def set_user_checklist
    @user_checklist = UserChecklist.includes(:user).find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_checklist_params
    params.require(:user_checklist).permit(:master_checklist, :user_id,
                                           :name, :description, :list_position, :date_completed)
    params
  end


  def progress_params
    params.require(:user_checklist_id)
    params
  end


  def authorize_user_checklist
    authorize @user_checklist
  end


  def authorize_user_checklist_class
    authorize UserChecklist
  end


  # @return [Hash] - a simple hash with the checklist id and date_completed
  def hash_id_date_completed(checklist)
    # use just the Date, not the time
    date_complete = checklist.date_completed.nil? ? nil : checklist.date_completed.to_date
    { checklist_id: checklist.id, date_completed: date_complete }
  end


  # Note this only returns information for the given UserChecklist that was changed.
  #  This does not return any information about any children that might have been changed.
  #
  # If the root of the checklist is 100% complete, send a message to the MembershipStatusUpdater
  #  so that the membership status can be checked and updated if need be.
  #
  # @return Hash - info about the user checklist item that was changed
  #      user_checklist_id: id of the user checklist item changed,
  #      date_completed: Date of when the user checklist item was completed (blank if not complete),
  #      overall_percent_complete: updated percent complete for the root checklist this one belongs to
  #
  def set_uc_and_kids_date_completed(action_params, new_date_completed = Time.zone.now)

    raise MissingUserChecklistParameterError, t('.missing-checklist-param-error') if action_params[:id].blank?

    user_checklist_id = action_params[:id]
    user_checklist = UserChecklist.find(user_checklist_id)

    if user_checklist
      if new_date_completed
        user_checklist.set_complete_including_children(new_date_completed)
      else
        user_checklist.set_uncomplete_including_children
      end
      new_percent_complete = user_checklist.root.percent_complete
      check_membership_status_if_complete(user_checklist.root, new_percent_complete)

      date_str = user_checklist.date_completed.blank? ? '' : user_checklist.date_completed.to_time.to_date

      { user_checklist_id: user_checklist_id,
        date_completed: date_str,
        overall_percent_complete: new_percent_complete }

    else
      raise UserChecklistNotFoundError, t('.not_found', id: user_checklist_id)
    end

  end


  # TODO - this should be from AppConfiguration
  def membership_guideline_root_user_checklist(uc_user)
    UserChecklist.find_by(name: 'Medlemsåtagande', user: uc_user)
  end

  # If the root of the checklist is 100% complete, send a message to the MembershipStatusUpdater
  #  so that the membership status can be checked and updated if need be.
  def check_membership_status_if_complete(checklist_root, percent_complete)
    MembershipStatusUpdater.instance.checklist_completed(checklist_root) if percent_complete == 100
  end


  def validate_and_authorize_xhr
    validate_xhr_request
    authorize_user_checklist_class
  end

end
