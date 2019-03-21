namespace :shf do
  desc 'load conditions to DB'
  task load_conditions: [:environment] do

    std_reminder_after_schedule = [2, 9, 14, 30, 60]

    std_reminder_before_schedule = [60, 30, 14, 2]

    # Add a Hash for each Condition to be created
    #
    conditions_to_create = [

        { class_name: 'MembershipExpireAlert',
          timing:     :before,
          config:     { days: std_reminder_before_schedule } },

        { class_name: 'MembershipLapsedAlert',
          timing:     :after,
          config:     { days: std_reminder_after_schedule } },

        { class_name: 'HBrandingFeeWillExpireAlert',
          timing:     :before,
          config:     { days: std_reminder_before_schedule } },

        { class_name: 'HBrandingFeeDueAlert',
          timing:     :after,
          config:     { days: std_reminder_after_schedule } },

        { class_name: 'CompanyInfoIncompleteAlert',
          timing:     :after,
          config:     { days: std_reminder_after_schedule } },


        { class_name: 'ShfAppNoUploadedFilesAlert',
          timing:     :after,
          config:     { days: [60, 30, 14, 9, 2] } },

        # days_to_keep - specifies number of (daily) backups to retain on production server
        # backup_directory - where daily backups are retained on production server;
        #                    omit or set to nil to use default directory
        { class_name: 'Backup',
          timing:     :every_day,
          config:     { days_to_keep:     { code_backup: 4,
                                            db_backup:   15 },
                        backup_directory: nil } },

        { class_name: 'DinkursFetch',
          timing:     :every_day },

        { class_name: 'MembershipStatusCheck',
          timing:     :every_day }
    ]


    # Start from scratch
    Condition.delete_all

    if Condition.create(conditions_to_create)
      puts "  #{conditions_to_create.size} Conditions were loaded into the db: #{conditions_to_create.map{|h_cond| h_cond[:class_name]}.join(', ')}"
    end

  end
end
