module AdminOnly

  class AppConfigurationController < ApplicationController

    before_action :authorize_admin
    before_action :get_app_configuration


    def show
    end


    def edit
    end


    def update
      membership_term_duration = duration_str_value_for(:membership_term)
      membership_expired_grace_period_duration = duration_str_value_for(:membership_expired_grace_period)

      if @app_configuration.update(app_config_params.merge(membership_term_duration)
                                                    .merge(membership_expired_grace_period_duration))
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
                    :membership_term_duration,
                    :membership_term_duration_days,
                    :membership_term_duration_months,
                    :membership_term_duration_years,
                    :membership_expired_grace_period_duration,
                    :membership_expired_grace_period_duration_days,
                    :membership_expired_grace_period_duration_months,
                    :membership_expired_grace_period_duration_years,
                    :payment_too_soon_days,
                    :membership_expiring_soon_days,
                    :membership_guideline_list_id)
    end


    # @return Hash - return empty Hash if there are no values in the parameters for the
    #  duration_name_duration parts
    #  else Hash has 1 key and value:
    #    key = duration_name with _duration appended (Symbol)
    #    value = The ISO8601 string for the Duration that is the sum of all of the parts
    def duration_str_value_for(duration_name)
      if duration_params_for(duration_name).empty?
        {}
      else
        { "#{duration_name}_duration".to_sym => duration_params_sum_for(duration_name).iso8601 }
      end
    end

    # All duration paramters should follow pattern:
    #   <duration_name>_duration_days
    #   <duration_name>_duration_months
    #   <duration_name>_duration_years
    def duration_params_for(duration_name)
      params.select{|p| p.to_s.start_with?(duration_name.to_s)}
    end


    def duration_params_sum_for(duration_name)
      ::ActiveSupport::Duration.days(params["#{duration_name}_duration_days".to_sym].to_i) +
        ::ActiveSupport::Duration.months(params["#{duration_name}_duration_months".to_sym].to_i) +
        ::ActiveSupport::Duration.years(params["#{duration_name}_duration_years".to_sym].to_i)
    end
  end

end
