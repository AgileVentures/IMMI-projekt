class UploadedFile < ApplicationRecord

  belongs_to :membership_application

  has_attached_file :actual_file
  validates_attachment :actual_file, content_type: {content_type: ['image/jpeg',
                                                                   'image/gif',
                                                                   'image/png',
                                                                   'text/plain',
                                                                   'text/rtf',
                                                                   'application/pdf',
                                                                   'application/msword',
                                                                   'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                                                   'application/vnd.ms-word.document.macroEnabled.12'],
                                                    message: I18n.t('membership_applications.uploads.invalid_upload_type')},
                                                    size: { in: 0..5.megabytes,
                                                            message: :file_too_large
                                                           }

end
