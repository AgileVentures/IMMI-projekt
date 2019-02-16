And(/^the following applications exist:$/) do |table|
  table.hashes.each do |hash|
    attributes = hash.except('user_email', 'categories', 'company_name', 'company_number')
    user = User.find_by(email: hash[:user_email].downcase)

    companies = []

    company_names = hash.delete('company_name')
    company_numbers = hash.delete('company_number')

    if company_names
      company_names.split(/(?:\s*,+\s*|\s+)/).each do |co_name|
        companies << Company.find_by(name: co_name)
      end
    else
      company_numbers.split(/(?:\s*,+\s*|\s+)/).each do |co_number|
        if (company = Company.find_by(company_number: co_number))
          companies << company
        else
          companies << FactoryBot.create(:company, company_number: co_number)
        end
      end
    end

    contact_email = hash['contact_email'] && ! hash['contact_email'].empty? ?
                    hash['contact_email'] : hash[:user_email]

    if (ma = user.shf_application)

      user.shf_application.companies << companies

    else
      num_categories = hash[:categories] ? 0 : 1

      ma = FactoryBot.build(:shf_application,
                            attributes.merge(user: user,
                            contact_email: contact_email,
                            create_company: false,
                            num_categories: num_categories))
      ma.companies = companies
    end

    if hash['categories']
      categories = []
      for category_name in hash['categories'].split(/\s*,\s*/)
        categories << BusinessCategory.find_by_name(category_name) unless
          ma.business_categories.where(name: category_name).exists?
      end
      ma.business_categories = categories
    end
    ma.save
  end
end

And(/^the application file upload options exist$/) do
  FactoryBot.create(:file_delivery_upload_now)
  FactoryBot.create(:file_delivery_upload_later)
  FactoryBot.create(:file_delivery_email)
  FactoryBot.create(:file_delivery_mail)
  FactoryBot.create(:file_delivery_files_uploaded)
end

When "I select files delivery radio button {capture_string}" do |option|
  # "option" must be a value from AdminOnly::FileDeliveryMethod::METHOD_NAMES

  delivery = AdminOnly::FileDeliveryMethod.get_method(option.to_sym)
  description = delivery.send("description_#{I18n.locale}".to_sym)

  step %{I select radio button "#{description}"}
end
