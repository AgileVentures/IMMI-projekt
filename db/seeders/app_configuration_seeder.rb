require_relative './simple_class_yaml_seeder'

module Seeders
  #--------------------------
  #
  # @class AppConfigurationSeeder
  #
  # @desc Responsibility: Seeds the AppConfiguration data
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2021-03-06
  #
  #--------------------------
  #
  class AppConfigurationSeeder

    SEEDED_CLASS = AdminOnly::AppConfiguration
    APP_CONFIG_FILES_DIR = File.join(__dir__, 'app_config_files')

    # Membership durations, number of days
    MEMBERSHIP_TERM_DURATION_STR = 'P1Y' # 1 year
    GRACE_PD_DURATION_STR = 'P2Y' # 2 years
    PAYMENT_TOO_SOON_DAYS = 60
    TERM_EXP_SOON_DAYS = 31

    # Guidelines checklist
    GUIDELINES_ROOT_TEXT = 'Medlemsåtagande'

    # ----------------------------------------------------------------

    def self.seed(log: nil)

      found_item = seeded_class.first
      if found_item.nil?
        seed_app_config
      else
        info_str = " INFO: #{self.name}.#{__method__} : #{seeded_class} already exists; not seeded: \n #{found_item.inspect}"
        tell info_str
        log_str info_str, log: log
        nil # don't return the found object; nothing was created
      end
    end


    def self.seed_app_config
      app_config = self::SEEDED_CLASS.new
      app_config.site_name = 'Sveriges Hundföretagare'
      app_config.site_meta_title = 'Hitta H-märkt hundföretag, hundinstruktör'
      app_config.site_meta_description = 'Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera.'
      app_config.site_meta_keywords = 'hund, hundägare, hundinstruktör, hundentreprenör, Sveriges Hundföretagare, svenskt hundföretag, etisk, H-märkt, hundkurs'
      app_config.site_meta_image_width = 1245
      app_config.site_meta_image_height = 620

      app_config.og_type = 'website'
      app_config.twitter_card_type = 'summary'
      app_config.facebook_app_id = ENV['SHF_FB_APPID']

      app_config.site_meta_image = app_config_file('Sveriges_hundforetagare_banner_sajt.jpg')
      app_config.shf_logo = app_config_file('shf_logo.png')
      app_config.h_brand_logo = app_config_file('h_brand_logo.png')
      app_config.sweden_dog_trainers = app_config_file('of_sweden_dog_trainers.png')

      app_config.email_admin_new_app_received_enabled = true

      app_config.membership_term_duration = MEMBERSHIP_TERM_DURATION_STR
      app_config.membership_expired_grace_period_duration = GRACE_PD_DURATION_STR
      app_config.payment_too_soon_days = PAYMENT_TOO_SOON_DAYS
      app_config.membership_expiring_soon_days = TERM_EXP_SOON_DAYS

      membership_guideline_list_root = AdminOnly::MasterChecklist.find_by(displayed_text: GUIDELINES_ROOT_TEXT)
      app_config.membership_guideline_list = membership_guideline_list_root

      app_config.save!
      app_config.update_site_meta_image_dimensions # ensure the dimensions are computed and saved
    end


    # @return [File] - file in the APP_CONFIG_FILES_DIR with the given file_name
    def self.app_config_file(file_name)
      File.new(File.join(app_config_files_dir, file_name))
    end


    def self.seeded_class
      self::SEEDED_CLASS
    end


    def self.app_config_files_dir
      APP_CONFIG_FILES_DIR
    end


    # Show the str to stdout
    # Having this method makes it easy to silence any puts output (e.g. for testing)
    def self.tell(str)
      puts(str)
    end


    # Write the string to the log as an info message, if log is not nil
    # Having this method makes it easy to silence any logging (e.g. for testing)
    def self.log_str(str, log: nil, level: :info)
      log.send(level, str) if log
    end
  end
end
