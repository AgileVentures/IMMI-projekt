module AdminOnly

  class FileDeliveryMethod < ApplicationRecord

    METHOD_NAMES = {
      upload_now: 'upload_now',
      upload_later: 'upload_later',
      email: 'email',
      mail: 'mail',
      files_uploaded: 'files_uploaded'
    }.freeze

    has_many :shf_applications, dependent: :nullify

    validates :description_en, :description_sv, presence: true

    validates :name, presence: true, uniqueness: true,
                     inclusion: { in: METHOD_NAMES.values }

    validates :default_option, uniqueness: true,
              :if => Proc.new { |record| record.default_option }

    scope :default, -> { where(default_option: true) }

    def self.get_method(name_key)

      unless name_key.is_a?(Symbol) && METHOD_NAMES.has_key?(name_key)
        raise ArgumentError, 'Argument must be a symbol and a known delivery name key'
      end

      find_by(name: METHOD_NAMES[name_key])
    end

    def email?
      name == METHOD_NAMES[:email]
    end

    def mail?
      name == METHOD_NAMES[:mail]
    end


    def description_for_locale(locale)
      text_method = "description_#{locale}".to_sym
      self.send(text_method)
    end

  end
end
