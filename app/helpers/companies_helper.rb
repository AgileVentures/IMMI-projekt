module CompaniesHelper

  def last_category_name company
    company.business_categories.any? ? company.business_categories.last.name : ''
  end


  def list_categories company
    if company.business_categories.any?
      company.business_categories.order(:name).map(&:name).join(" ")
    end
  end
end
