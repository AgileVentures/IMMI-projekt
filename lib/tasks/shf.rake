require 'active_support/logger'


namespace :shf do

  ACCEPTED_STATE = 'accepted' unless defined?(ACCEPTED_STATE)

  desc 'recreate db (current env): drop, setup, migrate, seed the db.'
  task :db_recreate => [:environment] do
    tasks = ['db:drop', 'db:create', 'db:migrate',
             'shf:load_regions', 'shf:load_kommuns', 'db:seed']
    tasks.each { |t| Rake::Task["#{t}"].invoke }
  end

  desc "import membership apps from csv file. Provide the full filename (with path)"
  task :import_membership_apps, [:csv_filename] => [:environment] do |t, args|

    require 'csv'
    require 'smarter_csv'

    usage = 'rake shf:import_membership_apps["./spec/fixtures/test-import-files/member-companies-sanitized-small.csv"]'

    DEFAULT_PASSWORD = 'whatever'

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
        file_encoding: 'UTF-8',
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

  desc "load regions data (counties plus 'Sverige' and 'Online')"
  task :load_regions => [:environment] do

    logfile = 'log/shf-regions.log'
    start_time = Time.now
    log = start_logging(start_time, logfile, "Regions create")

    # Populate the 'regions' table for Swedish regions (aka counties),
    # as well as 'Sverige' (Sweden) and 'Online'.  This is used to specify
    # the primary region in which a company operates.
    #
    # This uses the 'city-state' gem for a list of regions (name and ISO code).

    if Region.exists?
      log_and_show log, Logger::WARN, "Regions table not empty"
    else
      CS.states(:se).each_pair { |k, v| Region.create(name: v, code: k.to_s) }
      Region.create(name: 'Sverige', code: nil)
      Region.create(name: 'Online', code: nil)

      log_and_show log, Logger::INFO, "#{Region.count} Regions created"
    end

    log_and_show log, Logger::INFO, "Information was logged to: #{logfile}"
    finish_and_close_log(log, start_time, Time.now, "Regions create")
  end

  desc "load kommuns data (290 Swedish municipalities)"
  task :load_kommuns => [:environment] do

    require 'csv'
    require 'smarter_csv'

    logfile = 'log/shf-kommuns.log'
    start_time = Time.now
    log = start_logging(Time.now, logfile, "Kommuns create")

    if Kommun.exists?
      log_and_show log, Logger::WARN, "Kommuns table not empty"
    else
      SmarterCSV.process('lib/seeds/kommuner.csv').each do |kommun|
        Kommun.create(name: kommun[:name])
      end

      log_and_show log, Logger::INFO, "#{Kommun.count} kommuns created"
    end

    log_and_show log, Logger::INFO, "Information was logged to: #{logfile}"

    finish_and_close_log(log, start_time, Time.now, "Kommuns create")
  end


  # Geocode all Addresses.
  #   arguments:
  #    sleep:     number of seconds to sleep between each geocode request so we
  #                don't exceed the number of requests per <x> seconds
  #                for Google (or any other service)
  #                Note that 1 Address may require multiple geocode requests
  #                to get a valid locataion if the Address is a 'fake' address.
  #                See the note below about using :geocode_best_possible
  #                 default = 0.2 seconds
  #
  #    batch_num: number of objects in each batch (also so we don't exceed
  #               the number of requests per second)
  #                 default = 50
  #
  # We don't use the geocode:all  rake task
  # because we want to call the :geocode_best_possible method instead of
  # just using the 'geocoded_by :entire_address' that the geocode:all task
  # would use.  We do this because the fake data generated might not
  # create a real address, so the :entire_address might not really give us
  # the geolocation (latitude, longitude) info.
  #
  # This is based on the Geocoder gem geocode:all task.
  # @see https://github.com/alexreisner/geocoder#bulk-geocoding for more info
  #
  # We don't want to exceed the limit of number of geocoding calls per second
  #  (see the Google maps API limits).  We're using the free, standard plan
  # as of 2017-03-29, which means 50 requests per second.
  #
  # Examples:
  #  use the defaults:
  #    rake shf:geolocate_all_addresses
  #
  #  set the number of seconds to sleep between geocoding requests to 3 seconds:
  #    rake shf:geolocate_all_addresses[3]
  #
  #  set the number of records to request in each batch to 19, and number of seconds to sleep = 3:
  #    rake shf:geolocate_all_addresses[3, 19]
  #
  # Note that there are NO SPACES after the commas (between the arguments)
  #
  desc "geocode all addresses args=[sleep_time=2,batch_num=40] (those without latitude, longitude info) NO SPACES between arguments"
  task :geocode_all_addresses, [:sleep_time, :batch_num] => :environment do |_task_name, args|

    args.with_defaults(sleep_time: 0.2, batch_num: 50)

    Geocoder.configure( timeout: 20)   # geocoding service timeout (secs)

    logfile = 'log/shf-geocode.log'
    start_time = Time.now
    log = start_logging(start_time, logfile, "Geocode All Addresses (RAILS_ENV = #{Rails.env} arguments = #{args.each { |arg| arg.inspect} }  )")

    not_geocoded = Address.not_geocoded
    log_and_show log, Logger::INFO, "  #{not_geocoded.count} Addresses are not yet geocoded.  Will now geocode them..."
    Address.geocode_all_needed(sleep_between: args[:sleep_time].to_f, num_per_batch: args[:batch_num].to_i)

    log_and_show log, Logger::INFO, "  After running Address.geocode_all_needed(sleep_between: #{args[:sleep_time].to_f}, num_per_batch: #{args[:batch_num].to_i}), #{Address.not_geocoded.count} Addresses are not geocoded."

    log_and_show log, Logger::INFO, "Information was logged to: #{logfile}"
    finish_and_close_log(log, start_time, Time.now, "Geocode All Addresses")

  end


  # -------------------------------------------------

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
      puts_already_exists('Membership application', " org number: #{row[:company_number]}")
    else
      membership = MembershipApplication.create!(company_number: row[:company_number],
                                                 first_name: row[:first_name],
                                                 last_name: row[:last_name],
                                                 contact_email: user.email,
                                                 state: ACCEPTED_STATE,
                                                 membership_number: row[:membership_number],
                                                 user: user,
                                                 company: company
      )

      puts_created('Membership application', " org number: #{row[:company_number]}")

    end

    membership = find_or_create_category(row[:category1], membership) unless row[:category1].nil?
    membership = find_or_create_category(row[:category2], membership) unless row[:category2].nil?
    membership.save!

    if membership.accepted?
      membership.company = company
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
      region = Region.find_by name: region
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


  def start_logging(start_time = Time.now,
                    log_fn = 'log/import.log',
                    action = "Import")
    log = ActiveSupport::Logger.new(log_fn)
    log_and_show log, Logger::INFO, "#{action} started at #{start_time}"
    log
  end


# Severity label for logging (max 5 chars).
  LOG_LEVEL_LABEL = %w(DEBUG INFO WARN ERROR FATAL ANY)
    .each(&:freeze).freeze unless defined?(LOG_LEVEL_LABEL)


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


  def finish_and_close_log(log, start_time, end_time, action = "Import")
    duration = (start_time - end_time) / 1.minute
    log_and_show log, Logger::INFO, "=== #{action} finished at #{start_time}.\n"
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
