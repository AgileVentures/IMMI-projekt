module AdminOnly

  #--------------------------
  #
  # @class AppConfiguration
  #
  # @desc Responsibility: Aggregates discrete data items that are used to configure
  #  various aspects of the system (app).
  #  "configure" means settings that are more about customizing the application;
  # settings that can be changed after the application is running.
  #
  #  This is a Singleton. (Only 1 AppConfiguration instance exists/is needed.)
  #  This is enforced in the following ways:
  #    1. There is an index defined on the '' column in the table, and
  #       this index
  #       If the database detects an attempt to create more than 1 record
  #       (e.g. more than 1 index entry), it will throw a
  #       ActiveRecord::RecordNotUnique exception.
  #       See the comments for validates_uniqueness_of {ActiveRecord::Validations::UniquenessValidator::ClassMethods#validates_uniqueness_of}.
  #       Specifically, read the section "Concurrency and integrity"
  #    2. validates_inclusion_of :singleton_guard, in: [0]
  #       This ensures that the value of :singleton_guard can only be 0
  #       Combined with the unique index above, this ensures that there can
  #       only be 1 row in the table, and the singleton_guard value is always 0.
  #
  #    @url https://stackoverflow.com/questions/399447/how-to-implement-a-singleton-model
  #
  #
  # @file admin_only/app_configuration.rb
  #
  #--------------------------
  class AppConfiguration < ApplicationRecord


    # The "singleton_guard" column is a unique column which must always be set to '0'
    # This ensures that only one AppSettings row is created
    validates_inclusion_of :singleton_guard, in: [0]

    has_attached_file :chair_signature,
                      url: :url_for_images,
                      default_url: 'chair_signature.png',
                      styles: { standard: ['180x40#'] },
                      default_style: :standard

    has_attached_file :shf_logo,
                      url: :url_for_images,
                      default_url: 'shf_logo.png',
                      styles: { standard: ['257x120#'] },
                      default_style: :standard

    has_attached_file :h_brand_logo,
                      url: :url_for_images,
                      default_url: 'h_brand_logo.png',
                      styles: { standard: ['248x240#'] },
                      default_style: :standard

    has_attached_file :sweden_dog_trainers,
                      url: :url_for_images,
                      default_url: 'sweden_dog_trainers.png',
                      styles: { standard: ['234x39#'] },
                      default_style: :standard

    # The site meta image (used in OpenGraph meta info, etc.).
    # This must be shown via a public URL to (e.g. for Facebook). If it were
    # simply served up as an asset then we would manually have to apply the fingerprinting
    # as Sockets does.
    # This image _must be_ in the database; that's why there is no default for it
    # and  :validate_attachment_presence is used
    has_attached_file :site_meta_image,
                      url: :url_for_images


    #
    # This points to the MasterChecklist to use for the Membership Guidelines list.
    # Conceptually, 'belongs to' isn't quite right, but it is technically true that
    # the Application Configuration tracks the association to just one MasterChecklist.
    #
    # FIXME
     belongs_to :membership_guideline_list, class_name: 'AdminOnly::MasterChecklist', optional: true

    validates_presence_of :site_name, :site_meta_title

    validates_attachment_presence :site_meta_image


    validates_attachment_content_type :chair_signature, :shf_logo,
                                      :h_brand_logo, :sweden_dog_trainers,
                                      :site_meta_image,
                                      content_type: /\Aimage\/.*(jpeg|png)\z/

    validates_attachment_file_name :chair_signature, :shf_logo,
                                   :h_brand_logo, :sweden_dog_trainers,
                                   :site_meta_image,
                                   matches: [/png\z/, /jpe?g\z/]



    class << self

      # Need to use class << self so that the alias_method works on this
      # class method (:instance).
      # :alias_method only works for _instance methods_.
      # By using this style, the eigenclass (== the class of this class)
      # is being referred do and :instance is an instance method of the
      # eigenclass (the class of this class)

      def instance
        first_or_create!(singleton_guard: 0)
      end
      alias_method :config_to_use, :instance

    end

    after_save :update_site_meta_image_info

    after_update :clear_image_caches

    def clear_image_caches
      if saved_change_to_shf_logo_file_name?
        clear_proof_of_membership_image_caches
        clear_h_brand_image_caches
      elsif saved_change_to_chair_signature_file_name?
        clear_proof_of_membership_image_caches
      elsif saved_change_to_sweden_dog_trainers_file_name?
        clear_h_brand_image_caches
      end
    end

    def clear_proof_of_membership_image_caches
      User.clear_all_proof_of_membership_jpg_caches
    end

    def clear_h_brand_image_caches
      Company.clear_all_h_brand_jpg_caches
    end


    # Helpful method to get all images for the configuration
    def self.image_attributes
      [:site_meta_image,
       :chair_signature,
       :sweden_dog_trainers,
       :h_brand_logo,
       :shf_logo
      ].freeze
    end



    def image_attributes
      self.class.image_attributes
    end


    # Use MiniMagick to recompute the width and height for the site_meta_image
    # only update if the file exists
    def update_site_meta_image_dimensions

      if !site_meta_image.path.nil? && File.exist?(site_meta_image.path)
        image = MiniMagick::Image.open(site_meta_image.path)
        self.site_meta_image_height = image.height
        self.site_meta_image_width = image.width
        self.save
      end

    end


    # =========================================================================


    private


    def url_for_images
      '/storage/app_configuration/images/:attachment/:hashed_path/:style_:basename.:extension'.freeze
    end


    # If the site_meta_image changed, update the image dimensions.
    # Have to do this _after_ the attachment has been saved
    def update_site_meta_image_info
      update_site_meta_image_dimensions if saved_change_to_attribute?(:site_meta_image_updated_at)
    end

  end
end
