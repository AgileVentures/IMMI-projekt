module Shf
  module Generators

    #--------------------------
    #
    # @class  EmailAlertGenerator
    #
    # @desc Responsibility:  Generate everything needed to create a brand new
    #                        email alert.  There will still be code that will
    #                        have to be written.  See the usage of this generator
    #                        for more info.
    #
    # @author Ashley Engelund < weedySeaDragon @ GitHub >
    # @date 2019-03-07
    # @file email_alert_generator.rb
    #
    #--------------------------

    class EmailAlertGenerator < Rails::Generators::Base

      DEFAULT_TIMING = 'before'

      source_root File.expand_path('templates', __dir__)

      argument :alert_class_name,
               type: :string,
               desc: 'Alert class name. REQUIRED Ex: MembershipFeeDueAlert'

      # this is inherited from Rails::Generators::Base but we don't need it
      remove_class_option :skip_namespace


      class_option :mailer_class,
                   type:    :string,
                   default: 'MemberMailer',
                   desc:    "Mailer class that will call the alert. A minimal class will be created if it doesn't already exist."

      class_option :mailer_method,
                   type: :string,
                   desc: "Method name in the Mailer class (and the view name by Rails convention).\n" +
                             '                                             #   Default = <alert class name underscore>'

      class_option :req_class,
                   type: :string,
                   desc: "Requirements class name.  A class will be created.\n" +
                             '                                             #   Default class name = RequirementsFor<alert class name>'

      class_option :req_class_opposite,
                   type: :string,
                   desc: "Opposite Requirements class name. A class will be created.\n" +
                             '                                             #   Default class name = RequirementsFor<alert class name>Not'

      class_option :timing,
                   type: :string,
                   desc: 'Timing should be before or after. Default = before'


      def create_requirements_files
        template 'requirement_class.rb', File.join('app', 'models', 'reqs_updaters', "#{requirements_class.underscore}.rb")
        template 'requirement_not_class.rb', File.join('app', 'models', 'reqs_updaters', "#{requirements_opposite_class.underscore}.rb")
      end


      def create_requirements_rspecs

      end


      def create_conditions_alert_file
        template 'alert_class.rb', File.join('app', 'models', 'conditions_response', "#{class_underscored}.rb")
      end


      def create_conditions_rspecs

      end


      def create_mail_view_file
        template 'mail_view.rb', File.join('app', 'views', "#{mailer_class.underscore}", "#{mailer_method}.html.haml")
      end


      def insert_mailer_method
        create_mailer_class_file unless File.exist?(mailer_class_file)
        insert_into_file mailer_class_file,
                         mailer_method_code,
                         before: "\nend",
                         force:  false
      end


      def add_mailer_method_spec

      end


      def insert_mailer_preview_method
        create_mailer_preview_file unless File.exist?(mailer_preview_file)

        insert_into_file mailer_preview_file,
                         mailer_preview_code,
                         before: 'private',
                         force:  false
      end


      def insert_entry_into_locale_files

        locales.each do |locale|

          add_mailer_class_if_needed(locale)

          insert_into_file abs_locale_path(locale),
                           locale_entry,
                           after: "#{mailer_class.underscore}:",
                           force: false
        end
      end


      def insert_alert_condition_into_load_conditions_task
        create_load_conditions_file unless File.exist?(load_conditions_file)

        insert_into_file load_conditions_file, load_condition_entry,
                         after: ' conditions_to_create = [',
                         force: false
      end


      # ===========================
      #


      private


      #
      # Options - use given value or the default
      #

      def requirements_class
        options.fetch(:req_class, "RequirementsFor#{alert_class_name}")
      end


      def requirements_opposite_class
        options.fetch(:req_class_opposite, "#{requirements_class}Not")
      end


      def mailer_class
        options.fetch(:mailer_class, MemberMailer)
      end


      def mailer_method
        options.fetch(:mailer_method, class_underscored)
      end


      def timing
        if options.key?(:timing)
          timing = options[:timing]
          if timing_valid?(timing)
            timing
          else
            DEFAULT_TIMING
          end
        else
          DEFAULT_TIMING
        end
      end


      def timing_valid?(timing_value)
        %w(before after).include?(timing_value.to_s.downcase)
      end


      # -------------------------------------


      def class_underscored
        alert_class_name.underscore
      end


      def up_to_project_root
        File.join('..', '..', '..', '..')
      end


      def mailer_class_file
        File.absolute_path File.join(__dir__, up_to_project_root, 'app', 'mailers', "#{mailer_class.underscore}.rb")
      end


      def create_mailer_class_file
        template 'mailer_class.rb', File.absolute_path(File.join(__dir__, up_to_project_root, 'app', 'mailers', "#{mailer_class.underscore}.rb"))
      end


      def mailer_method_code
        "  def #{mailer_method}(member)\n\n" +

            "    set_mail_info __method__, member\n" +
            "    @member = member\n\n" +

            "    #FIXME set any other instance variables needed in the mail view\n\n" +

            "    mail to: recipient_email, subject: t('mailers.#{mailer_class.underscore}.#{mailer_method}.subject')\n" +
            "  end\n\n\n"
      end


      def mailer_preview_file
        File.absolute_path File.join(__dir__, up_to_project_root, 'spec', 'mailers', 'previews', "#{mailer_class.underscore}_preview.rb")
      end


      def create_mailer_preview_file
        template 'mailer_preview.rb', File.absolute_path(File.join(__dir__, up_to_project_root, 'spec', 'mailers', 'previews', "#{mailer_class.underscore}_preview.rb"))
      end


      def mailer_preview_code

        "\n\n  def #{class_underscored}\n\n" +
            "    #FIXME create or set the member as needed; change this as needed for the alert mailed out\n" +
            "    member = User.where(member: true).first\n\n" +
            "    #{mailer_class}.#{mailer_method}(member)\n" +
            "  end\n\n\n"
      end


      def locale_files
        locales.map { |locale| abs_local_path(locale) }
      end


      def locales
        [:en, :sv]
      end


      def locale_file_base
        File.absolute_path File.join(__dir__, up_to_project_root, 'config', 'locales')
      end


      def abs_locale_path(locale)
        File.join(locale_file_base, "#{locale}.yml")
      end


      def add_mailer_class_if_needed(locale)

        if created_locale_file?(locale) || options[:mailer_class]
          insert_into_file abs_locale_path(locale),
                           "\n\n    #{mailer_class.underscore}:\n",
                           after: "mailers:"
        end
      end


      def created_locale_file?(locale)

        locale_abs_file = abs_locale_path(locale)
        created_file    = false

        unless File.exist?(locale_abs_file)
          @current_locale_file = locale # so this can be accessed in the template
          create_locale_file(locale_abs_file)
          created_file = true
        end
        created_file
      end


      def create_locale_file(abs_locale_file_path)
        template 'locale.yml', abs_locale_file_path
      end


      def locale_entry
        "\n\n      #{mailer_method}:\n        subject: FIXME - need a subject for this email\n        message_text: FIXME - need sentences and locale entries for this email\n        error_sending:  FIXME - need text to display if there is a problem sending this email\n"
      end


      def load_conditions_file
        File.absolute_path(File.join(__dir__, up_to_project_root, 'lib', 'tasks', 'conditions', 'load_conditions.rake'))
      end


      def create_load_conditions_file
        template 'load_conditions.rake', File.absolute_path(File.join(__dir__, up_to_project_root, 'lib', 'tasks', 'conditions', 'load_conditions.rake'))
      end


      def load_condition_entry
        "\n\n        # FIXME: Check the timing for this alert: should it be _before_ or _after_ ?\n" +
            "        # FIXME: check the config[:days] to see if the schedule is correct\n" +
            "        { alert_class_name: '#{alert_class_name}',\n" +
            "            timing:     :#{timing},\n" +
            "            config:     { days: std_reminder_#{timing}_schedule } }, \n\n"
      end

    end
  end
end
