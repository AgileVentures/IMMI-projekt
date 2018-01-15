module AdminOnly

  class DashboardController < ApplicationController

    before_action :authorize_dashboard
    before_action :set_data_gatherer


    def index
    end


    def show
    end


    def show_recent_activity
      respond_to do |format|
        format.js
      end
    end


    # WIP to change the timeframe for "recent" data.  See commented out .row in the _recent_activity partial
    def update_timeframe
      # params['data_gatherer']['timeframe']
      if request.xhr?

        begin
          @data_gatherer.timeframe = params['data_gatherer']['timeframe'].to_i
          head :ok
        rescue ArgumentError
          head :error # return an error to the xhr call
        end

      end

    end


    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def dashboard_params
      params.require(:admin_only_dashboard).permit(:name_sv, :description_sv, :name_en, :description_en, :is_custom,
                                                   :data_gatherer, :data_gatherer[:timeframe])
    end


    def self.policy_class
      AdminOnly::DashboardPolicy
    end


    # manually set and check the pundit policy because the default Pundit policy finder chokes on this (we do not have a 'Dashboard' class)
    def authorize_dashboard
      query ||= params[:action].to_s + "?"

      policy = AdminOnly::DashboardPolicy.new(current_user, nil)
      unless policy.public_send(query)
        raise NotAuthorizedError, query: query, record: current_user, policy: policy
      end

    end


    # load the object that will gather all of the data to be displayed
    def set_data_gatherer
      @data_gatherer = AdminOnly::DataGatherer.new
    end

  end

end
