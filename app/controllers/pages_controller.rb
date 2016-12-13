class PagesController < ApplicationController
  include HighVoltage::StaticPage

  before_action :authorize_page, only: [:update, :show, :edit]

  private

  def authorize_page
    authorize :page
  end

end
