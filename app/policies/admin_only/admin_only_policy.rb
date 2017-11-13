module AdminOnly

# An abstract super class for those classes that only Admins have permission to access
  class AdminOnlyPolicy < ApplicationPolicy

    def show?
      @user.admin?
    end


    def index?
      @user.admin?
    end


    def update?
      @user.admin?
    end


    def create?
      @user.admin?
    end


    def new?
      create?
    end

  end

end
