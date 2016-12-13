class AdminController < ApplicationController

  def index
    @membership_applications = MembershipApplication.all
  end

end
