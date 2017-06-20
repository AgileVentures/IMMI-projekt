class Visitor

  def is_admin?
    false
  end

  def admin?
    false
  end

  def is_member?
    false
  end

  def is_member_or_admin?
    false
  end

  def has_membership_application?
    false
  end

  def has_company?
    false
  end

  def is_in_company_numbered?(_company_number_)
    false
  end
end
