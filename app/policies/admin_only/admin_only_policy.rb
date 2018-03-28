module AdminOnly

# An abstract super class for those classes that only Admins have permission to access
  class AdminOnlyPolicy < ApplicationPolicy

    # All methods do the same thing:  the user must be the admin

    all_actions_to_authorize = [:show?, :index?, :new?, :create?, :edit?,
                                :update?, :destroy?]

    all_actions_to_authorize.each do |method|

      define_method(method) do
        user.admin?
      end

    end

  end

end
