module ShfApplicationMailerHelper

# this could be an Adapter.  But for now, this is OK
  def shf_app_to_html(shf_app)
    app_as_html_str = ''

    app_as_html_str << field_or_none(I18n.t('name'),
                                     shf_app.user.full_name, tag_options: { class: 'full-name' })
    app_as_html_str << field_or_none(I18n.t('activerecord.attributes.user.email'),
                                     shf_app.user.email, tag_options: { class: 'login-email' })

    app_as_html_str << field_or_none(I18n.t('activerecord.attributes.shf_application.contact_email'),
                                     shf_app.contact_email, tag_options: { class: 'contact-email' })
    app_as_html_str << field_or_none(I18n.t('activerecord.attributes.shf_application.phone_number'),
                                     shf_app.phone_number, tag_options: { class: 'phone-number' })

    app_as_html_str << field_or_none(I18n.t('activerecord.attributes.shf_application.company_number'),
                                     shf_app.company_numbers, tag_options: { class: 'company-numbers' })

    business_cat_names = shf_app.business_categories.order(:name).map(&:name)
    business_cat_str   = business_cat_names.join(', ')
    app_as_html_str << field_or_none(I18n.t('activerecord.models.business_category', count: business_cat_names.size),
                                     business_cat_str, tag_options: { class: 'business-categories' })

    app_as_html_str << shf_app_uploads_choice_to_html(shf_app)

    app_as_html_str << shf_app_uploads_to_html(shf_app)

    app_as_html_str.html_safe
  end


# ==================================================================


  private


  def shf_app_uploads_choice_to_html(shf_app)
    content_tag(:p,
                I18n.t('mailers.shf_application_mailer.acknowledge_received.upload_choice_intro') +
                shf_app.file_delivery_method.description_for_locale(I18n.locale),
                class: 'upload-files-choice')

  end


  def shf_app_uploads_to_html(shf_app)

    html_str = ''
    num_files_uploaded = shf_app.uploaded_files.size

    if num_files_uploaded < 1
      html_str << content_tag(:p, I18n.t('shf_applications.uploads.no_files'), class: 'file-uploads-title no-files-uploaded')
    else
      html_str << content_tag(:p, I18n.t('shf_applications.uploads.files_uploaded'), class: 'file-uploads-title')

      html_str << content_tag(:ul, '', class: 'file-upload-list') do

        filenames = shf_app.uploaded_files.map(&:actual_file_file_name)
        filenames.each do | filename |
          html_str << content_tag(:li, filename, class: 'file-upload-filename')
        end

      end
    end

    html_str
  end

end
