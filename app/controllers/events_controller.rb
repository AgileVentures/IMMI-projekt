class EventsController < ApplicationController
  before_action :set_company

  def fetch_from_dinkurs
    authorize Event.new(company: @company)
    FetchEventsFromDinkursJob.perform_later(@company)
    head :ok
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end
end
