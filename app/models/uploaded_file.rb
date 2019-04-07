class UploadedFile < ApplicationRecord

  ALLOWED_FILE_TYPES = {
    %w(.jpeg .jpg) => 'image/jpeg',
    %w(.gif) => 'image/gif',
    %w(.png) => 'image/png',
    %w(.txt) => 'text/plain',
    %w(.rtf) => 'text/rtf',
    %w(.pdf) => 'application/pdf',
    %w(.doc .dot) => 'application/msword',
    %w(.docx) => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    %w(.docm) => 'application/vnd.ms-word.document.macroEnabled.12'
  }

  belongs_to :shf_application
  counter_culture :shf_application

  has_attached_file :actual_file
  validates_attachment :actual_file, content_type: {content_type: ALLOWED_FILE_TYPES.values,
                                                    message: I18n.t('shf_applications.uploads.invalid_upload_type')},
                                                    size: { in: 0..5.megabytes,
                                                            message: :file_too_large
                                                           }
=begin

  If the size validation fails, then the error message is looked up in the
  locale file(s) starting based on I18n conventions, then adding 'actual_file_file'
  as the attribute, and finally adding 'file_too_large' which is what is specified by the
  'message' key within the 'size' hash above.  For some reason, the Paperclip gem will
  raise (or find) 2 error messages:  the one for 'actual_file_file_size' and
  one for 'actual_file'.

  Here's an example of the error messages in the en.yml locale file:

  en:
    errors:
      models:
        uploaded_file:
          attributes:
            actual_file_file_size:
              file_too_large: 'The uploaded file is too big.'
            actual_file:
              file_too_large: 'The uploaded file size must be smaller than %{max}. (Your file is %{value} bytes.)'


  Paperclip makes some instance variables available to you so that you can use them
  in the error messages if you want.  These variables are made available by the
  size validator:  Paperclip::Validators::AttachmentSizeValidator.  Specifically,
  the 'validate_each' method adds the instance variables :min, :max, and :count
  available and passes them to the error messages.  You can choose to
  use them in the messages (in the locale .yml files) or not.

    min = the lower bound of the file size
    max = the upper bound of the file size
    count = the upper bound, converted to 'human_size' by ActiveSupport::NumberHelper.number_to_human_size(size)
    value = the actual size of the file



=end

end
