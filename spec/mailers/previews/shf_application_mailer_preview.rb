# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'

class ShfApplicationMailerPreview < ActionMailer::Preview

  include PickRandomHelpers


  UPLOAD_LATER_OPTIONS = [:upload_later, :email, :mail]

  def app_approved
    ShfApplicationMailer.app_approved(random_shf_app(:accepted))
  end


  def acknowledge_received_no_files_uploaded
    no_uploads = ShfApplication.where.not(id: [UploadedFile.pluck(:shf_application_id)])
    if no_uploads.count == 0
      # create an application with no uploads by removing all the uploads from an app
      new_app = get_new_app
      new_app.uploaded_files.delete_all
      shf_app_no_uploads = new_app
    else
      shf_app_no_uploads = no_uploads.first
    end

    # change the delivery method so it makes sense. Otherwise the mail preview is confusing.
    random_delivery_method = UPLOAD_LATER_OPTIONS.sample
    no_uploads.update(file_delivery_method:  AdminOnly::FileDeliveryMethod.get_method(random_delivery_method) )

    ShfApplicationMailer.acknowledge_received(shf_app_no_uploads)
  end


  def acknowledge_received_with_files_uploaded
    apps_with_uploads = ShfApplication.joins(:uploaded_files)
    if apps_with_uploads.count == 0
      new_app = get_new_app
      upload_random_num_files(new_app)
      app_with_uploads = new_app
    else
      app_with_uploads = apps_with_uploads.first
    end

    if UPLOAD_LATER_OPTIONS.include? app_with_uploads.file_delivery_method.name.to_sym
      # change the delivery method so it makes sense. Otherwise the mail preview is confusing.
      uploaded = AdminOnly::FileDeliveryMethod.get_method(:files_uploaded)
      app_with_uploads.update(file_delivery_method: uploaded)
    end

    ShfApplicationMailer.acknowledge_received(app_with_uploads)
  end

  private

  def get_new_app
    ShfApplication.where(state:'new').first
  end
end
