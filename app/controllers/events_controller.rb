class EventsController < ApplicationController
  before_action :set_company

  def index
    @events = @company.events
  end

  def show
    @event = @company.events.find(params[:id])
  end

  def fetch_from_dinkurs
    authorize Event.new(company: @company)
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end
end
