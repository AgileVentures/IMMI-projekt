module AdminOnly

  class DashboardPolicy < AdminOnlyPolicy

    def update_timeframe?
      update?
    end

    def show_recent_activity?
      show?
    end
  end

end
