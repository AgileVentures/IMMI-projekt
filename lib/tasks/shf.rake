require 'active_support/logger'


namespace :shf do

  desc 'recreate db (current env): drop, setup, migrate, seed the db.'
  task :db_recreate => [:environment] do
    tasks = ['db:drop', 'db:setup', 'db:migrate', 'db:seed']
    tasks.each { |t| Rake::Task["#{t}"].invoke }
  end

  desc "import membership apps from csv file. Provide the full filename (with path)"
  task :import_membership_apps, [:csv_filename] => [:environment] do |t, args|

    require 'csv'
    require 'smarter_csv'

    usage = 'rake shf:import_membership_apps["./spec/fixtures/test-import-files/member-companies-sanitized-small.csv"]'

    DEFAULT_PASSWORD = 'whatever'
    ACCEPTED_STATUS = 'Godkänd'

    headers_to_columns_mapping = {
        membership_number: :membership_number,
        email: :email,
        company_number: :company_number,
        first_name: :first_name,
        last_name: :last_name,
        company_name: :company_name,
        street: :street,
        post_code: :post_code,
        stad: :city,
        region: :region,
        phone_number: :phone_number,
        website: :website,
        category1: :category1,
        category2: :category2
    }

    csv_options = {
        col_sep: ';',
        headers_in_file: true,
        remove_empty_values: false,
        remove_zero_values: false,
        file_encoding: 'ISO-8859-1',
        key_mapping: headers_to_columns_mapping
    }

    logfile = 'log/import.log'
    start_time = Time.now
    log = start_logging(start_time, logfile)

    if args.has_key? :csv_filename

      if File.exist? args[:csv_filename]

        csv = SmarterCSV.process(args[:csv_filename], csv_options)
        #csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

        num_read = 0
        error_rows = 0
        csv.each do |row|
          begin
            import_a_member_app_csv(row, log)
            num_read += 1
          rescue ActiveRecord::RecordInvalid => invalid_info
            error_rows += 1
            log_and_show(log, Logger::ERROR, "#{invalid_info.record.errors.full_messages.join(", ")}")
          end
        end

        log_and_show log, Logger::INFO, "\nFinished.  Read #{num_read + error_rows} rows.\n  #{num_read} were valid and their information was imported.\n  #{error_rows} had errors."

      else
        log_file_doesnt_exist_and_close(log, args[:csv_filename], start_time)
        finish_and_close_log(log, start_time, Time.now)
        raise LoadError
      end

    else
      log_must_provide_filename_and_close(log, usage, start_time)
      raise "ERROR: You must specify a .csv filename to import. Ex: #{usage}"
    end

    log_and_show log, Logger::INFO, "Information was logged to: #{logfile}"
    finish_and_close_log(log, start_time, Time.now)
  end


  def import_a_member_app_csv(row, log)

    log_and_show log, Logger::INFO, "Importing row: #{row.inspect}"

    if (user = User.find_by(email: row[:email]))
      puts_already_exists 'User', row[:email]
    else
      user = User.create!(email: row[:email], password: DEFAULT_PASSWORD)
      puts_created 'User', row[:email]
    end

    company = find_or_create_company(row[:company_number], user.email,
                                     name: row[:company_name],
                                     street: row[:street],
                                     post_code: row[:post_code],
                                     city: row[:city],
                                     region: row[:region],
                                     phone_number: row[:phone_number],
                                     website: row[:website])

    if (membership = MembershipApplication.find_by(user: user.id))
      puts_already_exists('Membership application', " org number: #{row[:company_number]}, status: #{row[:status]}")
    else
      membership = MembershipApplication.create!(company_number: row[:company_number],
                                                 first_name: row[:first_name],
                                                 last_name: row[:last_name],
                                                 contact_email: user.email,
                                                 status: ACCEPTED_STATUS,
                                                 membership_number: row[:membership_number],
                                                 user: user
      )

      puts_created('Membership application', " org number: #{row[:company_number]}, status: #{row[:status]}")

    end


    membership = find_or_create_category( row[:category1], membership) unless row[:category1].nil?
    membership = find_or_create_category( row[:category2], membership) unless row[:category2].nil?
    membership.save!

    if membership.status == ACCEPTED_STATUS
      membership.company = company
      user.is_member = true
      user.save!
    end

  end




  def find_or_create_category(category_name, membership)
    category = BusinessCategory.find_by_name(category_name)
    if category
      puts_already_exists 'Category', "#{category_name}"
    else
      category = BusinessCategory.create!(name: category_name)
      puts_created 'Category', "#{category_name}"
    end
    membership.business_categories << category
    membership
  end


  def find_or_create_company(company_num, email,
                             name:,
                             street:,
                             post_code:,
                             city:,
                             region:,
                             phone_number:,
                             website:)

    company = Company.find_by_company_number(company_num)
    if company
      puts_already_exists 'Company', "#{company_num}"
    else
      Company.create!(company_number: company_num,
                      email: email,
                      name: name,
                      street: street,
                      post_code: post_code,
                      city: city,
                      region: region,
                      phone_number: phone_number,
                      website: website)

      company = Company.find_by_company_number(company_num)
      puts_created 'Company', company.company_number
    end
    company
  end


  def start_logging(start_time = Time.now, log_fn = 'log/import.log')
    log = ActiveSupport::Logger.new(log_fn)
    log_and_show log, Logger::INFO, "Import started at #{start_time}"
    log
  end


# Severity label for logging (max 5 chars).
  LOG_LEVEL_LABEL = %w(DEBUG INFO WARN ERROR FATAL ANY).each(&:freeze).freeze


  def log_level_text(log_level)
    LOG_LEVEL_LABEL[log_level] || 'ANY'
  end


  def log_and_show(log, log_level, message)
    log.add log_level, message
    puts "#{log_level_text(log_level)}: #{message}"
  end


  def log_file_doesnt_exist_and_close(log, filename, start_time, end_time=Time.now)
    log_and_show log, Logger::ERROR, "#{filename} does not exist. Nothing imported"
    finish_and_close_log(log, start_time, end_time)
  end


  def log_must_provide_filename_and_close(log, usage_example, start_time, end_time=Time.now)
    log_and_show(log, Logger::ERROR, "You must specify a .csv filename to import.\n  Ex: #{usage_example}")
    finish_and_close_log(log, start_time, end_time)
  end


  def finish_and_close_log(log, start_time, end_time)
    duration = (start_time - end_time) / 1.minute
    log_and_show log, Logger::INFO, "Import finished at #{start_time}."
    log.close
    log
  end


  def puts_created(item_type, item_name)
    puts " #{item_type} created and saved: #{item_name}"
  end


  def puts_already_exists(item_type, item_name)
    puts " #{item_type} already exists: #{item_name}"
  end


  def puts_error_creating(item_type, item_name)
    puts " ERROR: Could not create #{item_type} #{item_name}.  Skipped"
  end


end

