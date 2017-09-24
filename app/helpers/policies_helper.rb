module PoliciesHelper
  def is_in_company?
    user.is_in_company_numbered?(record.company_number)
  end
end
