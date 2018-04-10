class Visitor

  def admin?
    false
  end

  def member?
    false
  end

  def member_or_admin?
    false
  end

  def has_shf_application?
    false
  end

  def shf_application
    nil
  end

  def in_company_numbered?(_company_number_)
    false
  end

  def id
    0
  end
end
