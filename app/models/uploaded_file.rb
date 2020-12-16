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

  IMAGE_FILE_TYPES = %w[image/jpeg image/gif image/png]

  DEFAULT_FILE_ICON = 'far fa-file-alt'
  UNKNOWN_FILE_ICON = 'far fa-question-circle'
  FILE_TYPE_ICONS = {
    'text/plain': 'far fa-file-alt',
    'text/rtf': DEFAULT_FILE_ICON,
    'application/pdf': 'far fa-file-pdf',
    'application/msword': 'far fa-file-word',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'far fa-file-word',
    'application/vnd.ms-word.document.macroEnabled.12': 'far fa-file-word'
  }


  belongs_to :user
  belongs_to :shf_application, optional: true
  counter_culture [:user, :shf_application]

  has_attached_file :actual_file
  validates_attachment :actual_file, content_type: { content_type: ALLOWED_FILE_TYPES.values,
                                                     message: I18n.t('activerecord.errors.models.uploaded_file.attributes.actual_file_file_content_type.invalid_type') },
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

  # The .sort_by_user_full_name...   methods (=scopes) are used by the Ransack gem to
  #   do sorting. These methods are a way to do sorting on a joined table
  #   (e.g. the 'belongs_to :user' association).
  #   @see https://github.com/activerecord-hackery/ransack#ransacks-sort_link-helper-creates-table-headers-that-are-sortable-links

  def self.sort_by_user_full_name(sort_direction = :asc)
    joins(:user).order(User.arel_table[:first_name].send(sort_direction),
                       User.arel_table[:last_name].send(sort_direction))
  end

  def self.sort_by_user_full_name_asc
    sort_by_user_full_name(:asc)
  end

  def self.sort_by_user_full_name_desc
    sort_by_user_full_name(:desc)
  end

  def self.allowed_file_types
    ALLOWED_FILE_TYPES
  end


  def allowed_file_types
    self.class.allowed_file_types
  end

  def can_edit?
    shf_application.present? ?  shf_application.can_edit_delete_uploads? : true
  end

  def can_delete?
    can_edit?
  end

  def image?
    IMAGE_FILE_TYPES.include? actual_file&.content_type
  end

  def icon
    actual_file ? FILE_TYPE_ICONS[actual_file.content_type.to_sym]  : UNKNOWN_FILE_ICON
  end
end
