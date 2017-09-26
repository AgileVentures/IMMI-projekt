module PoliciesHelper
  def is_in_company?(company)
    user.is_in_company_numbered?(company.company_number)
  end
end
