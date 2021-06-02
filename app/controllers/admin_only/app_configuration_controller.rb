module AdminOnly

  class AppConfigurationController < ApplicationController

    before_action :authorize_admin
    before_action :get_app_configuration


    def show
    end


    def edit
    end


    def update
      if @app_configuration.update(app_config_params)
        redirect_to @app_configuration, notice: t('.success')
      else
        helpers.flash_message(:alert, "#{t('.error')}: #{@app_configuration.errors.full_messages.join(', ')}")
        render :edit
      end
    end

    # FIXME if the membership guideline list was changed,
    #  need to track _any_ membership guideline list that has been used in the past because
    #  we need a way to choose the master checklist for a user (that is: the membership guideline user checklist for a user).
    #  If this was changed...
    #   1) keep a list of all master checklists that have been used as a membership guideline list
    #   2) when a user checklist is created by the memebership guideline factory, mark it somehow as the
    #     _current_ membership guideline list.
    #

    # =====================================================================


    private


    def authorize_admin
      authorize AdminOnly::AppConfiguration
    end


    def get_app_configuration
      @app_configuration = AppConfiguration.instance
    end


    def app_config_params
      params.require(:admin_only_app_configuration)
          .permit(:chair_signature, :shf_logo, :h_brand_logo, :sweden_dog_trainers,
                  :email_admin_new_app_received_enabled,
                  :site_name,
                  :site_meta_title, :site_meta_description, :site_meta_keywords,
                  :og_type,
                  :twitter_card_type,
                  :facebook_app_id,
                  :site_meta_image,
                  :membership_expired_grace_period_duration,
                  :membership_term_duration,
                  :payment_too_soon_days,
                  :membership_guideline_list_id)
    end
  end

end
