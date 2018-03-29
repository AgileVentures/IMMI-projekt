module AdminOnly

  class AppConfigurationController < ApplicationController

    before_action :authorize_admin
    before_action :get_app_configuration

    def edit
    end

    def update
      if @app_configuration.update(app_config_params)
        redirect_to root_path, notice: t('.success')
      else
        flash.now[:alert] = t('.error')
        render :edit
      end
    end

    private

    def authorize_admin
      authorize AdminOnly::AppConfiguration
    end

    def get_app_configuration
      return @app_configuration = AppConfiguration.last if AppConfiguration.any?

      @app_configuration = AppConfiguration.new
    end

    def app_config_params
      # Need to use "fetch" here (instead of "require") as the edit form
      # currently contains only file_field(s), and if the user clicks
      # "Submit" without changing any of those fields (that is, without
      # specifying one or more files to upload), then those fields will
      # not be added to the params, and there will be no
      # "admin_only_admin_page" key (for those fields) in the params).
      params.fetch(:admin_only_app_configuration, {})
        .permit(:chair_signature, :shf_logo)
    end
  end

end
