module AdminOnly

  class UserAccountController < AdminOnlyController

    include SetAppConfiguration

    before_action :get_user, except: [:update_membership_status_all]
    before_action :set_app_config, only: [:edit, :update]


    def edit
    end


    def update
      if @user.update(user_account_params)
        redirect_to @user, notice: t('.success')
      else
        helpers.flash_message(:alert, t('.error'))

        @user.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }

        render :show
      end
    end


    def update_membership_status_all
      begin

        membership_updater = MembershipStatusUpdater.instance
        reason_update_happened = t('.reason_update_happened')
        do_send_email_option = false

        users = User.where(membership_status: User.membership_statuses - [:former_member])
        users.each do |user|
          unless user.admin?
            membership_updater.check_grant_renew_and_status(user,
                                                            nil,
                                                            reason_update_happened,
                                                            send_email: do_send_email_option)
          end
        end

        respond_to do |format|
          format.html { redirect_to users_url, notice: t('.success') }
          format.js { render json: { status: :ok } }
        end

      rescue => e
        helpers.flash_message(:alert, t('.error'))
        redirect_to(request.referer.present? ? :back : root_path)
      end
    end


    def update_membership_status_all_success

    end


    private

    def get_user
      @user = User.find(params[:user_id])
    end


    def user_account_params

      # if membership_number is blank then set to nil.
      # The User model allows for blank membership_number.
      # However, the DB (PG) has a unique constraint on this attribute and
      # hence will raise an exception if the attribute is an empty string
      # (one of which will already exist in the DB).
      # Since that exception occurs after model validation, the "update" method
      # cannot rescue this exception. (the DB considers "NULL" values unequal,
      # so "nil" will not trigger the exception on save.)

      if params[:user][:membership_number].blank?
        params[:user][:membership_number] = nil
      end

      params.require(:user)
            .permit(:membership_number,
                    :date_membership_packet_sent)
    end

  end
end
