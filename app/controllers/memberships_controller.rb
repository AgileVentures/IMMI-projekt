class MembershipsController < ApplicationController
  def new
    @membership = MembershipApplication.new
  end

  def create
  end
end
