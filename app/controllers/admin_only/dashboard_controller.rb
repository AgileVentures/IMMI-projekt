module AdminOnly

  class DashboardController < ApplicationController

    before_action :authorize_admin
    before_action :set_data_gatherer


    def index
    end


    # WIP to change the timeframe for "recent" data.
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


    def authorize_admin
      authorize :'admin_only/dashboard'
    end


    # load the object that will gather all of the data to be displayed
    def set_data_gatherer
      @data_gatherer = AdminOnly::DataGatherer.new
    end

  end

end
