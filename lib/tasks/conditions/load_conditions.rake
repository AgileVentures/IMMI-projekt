namespace :shf do
  desc 'load conditions to DB'
  task :load_conditions => [:environment] do
    # Start from scratch
    Condition.delete_all

    Condition.create(class_name: 'MembershipExpireAlert',
                     timing: :before,
                     config: { days: [60, 30, 14, 2] })

    # days_to_keep - specifies number of (daily) backups to retain on production server
    # backup_directory - where daily backups are retained on production server;
    #                    omit or set to nil to use default directory
    Condition.create(class_name: 'Backup',
                     timing: :every_day,
                     config: { days_to_keep: { code_backup: 4,
                                               db_backup: 15 },
                               backup_directory: nil })
  end
end
