# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  include PoliciesHelper

  def fetch_from_dinkurs?
    user.admin? || is_in_company?(record.company)
  end
end
