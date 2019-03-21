And(/^the following applications exist:$/) do |table|

  # Hash value "is_legacy" indicates an application that was created before we
  # required the user to specify a file-delivery method (upload, email, etc.) for
  # application files.
  # We have to skip validation for such an application since it will fail with
  # current validation rules.

  table.hashes.each do |hash|

    attributes = hash.except('user_email', 'categories', 'company_name',
                             'company_number', 'is_legacy')
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

    legacy_app = hash['is_legacy'] == 'true' ? true : false

    if (ma = user.shf_application)

      user.shf_application.companies << companies

    else
      num_categories = hash[:categories] ? 0 : 1

      ma_attributes = attributes.merge(user: user,
                                       contact_email: contact_email,
                                       create_company: false,
                                       num_categories: num_categories)

      if legacy_app
        ma = FactoryBot.build(:shf_application, :legacy_application,
                              ma_attributes)
      else
        ma = FactoryBot.build(:shf_application,
                              ma_attributes)
      end
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


    if legacy_app
      # We save without validation - so, confirm that the **only** validation errors
      # would be associated with the missing file-delivery method.
      ma.valid?
      expect(ma.errors.keys)
        .to match_array [:file_delivery_method,
                         :'user.shf_application.file_delivery_method']
    end

    ma.save(validate: (legacy_app ? false : true))
  end
end

And(/^the application file upload options exist$/) do
  FactoryBot.create(:file_delivery_upload_now) if AdminOnly::FileDeliveryMethod.find_by(name: 'upload_now').nil?
  FactoryBot.create(:file_delivery_upload_later) if AdminOnly::FileDeliveryMethod.find_by(name: 'upload_later').nil?
  FactoryBot.create(:file_delivery_email) if AdminOnly::FileDeliveryMethod.find_by(name: 'email').nil?
  FactoryBot.create(:file_delivery_mail) if AdminOnly::FileDeliveryMethod.find_by(name: 'mail').nil?
  FactoryBot.create(:file_delivery_files_uploaded) if AdminOnly::FileDeliveryMethod.find_by(name: 'files_uploaded').nil?
end

When "I select files delivery radio button {capture_string}" do |option|
  # "option" must be a value from AdminOnly::FileDeliveryMethod::METHOD_NAMES

  delivery = AdminOnly::FileDeliveryMethod.get_method(option.to_sym)
  description = delivery.send("description_#{I18n.locale}".to_sym)

  step %{I select radio button "#{description}"}

  # manually make the save button enabled:
  page.evaluate_script("$('.app-submit').prop('disabled', false)")

end
