require 'active_support/logger'


namespace :shf do

  ACCEPTED_STATE = 'accepted' unless defined?(ACCEPTED_STATE)
  LOG_FILE = 'log/shf_tasks' unless defined?(LOG_FILE)

  desc 'load Dinkurs events for companies'
  task :dinkurs_load => [:environment] do

    LOG = 'log/dinkurs_load_events'

    ActivityLogger.open(LOG, 'SHF_TASK', 'Load Dinkurs Events') do |log|

      Company.where.not(dinkurs_company_id: [nil, '']).order(:id).each do |company|

        company.fetch_dinkurs_events
        company.reload
        log.record('info', "Company #{company.id}: #{company.events.count} events.")

      end
    end
  end

  desc 'recreate db (current env): drop, setup, migrate, seed the db.'
  task :db_recreate => [:environment] do
    Rake::Task['db:drop'].invoke if database_exists?
    tasks = ['db:create', 'db:migrate',
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

    log = ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Import CSV')

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
            log.record('error', "#{invalid_info.record.errors.full_messages.join(", ")}")
          end
        end

        msg = "\nRead #{num_read + error_rows} rows.\n" +
              "#{num_read} were valid and their information was imported.\n" +
              "#{error_rows} had errors."
        log.record('info', msg)

      else
        log.record('error', "#{args[:csv_filename]} does not exist. Nothing imported")
        log.close
        raise LoadError
      end

    else
      msg = "You must specify a .csv filename to import.\n  Ex: #{usage}"
      log.record('error', msg)
      log.close
      raise "ERROR: You must specify a .csv filename to import. Ex: #{usage}"
    end

    log.close
  end

  desc "load regions data (counties plus 'Sverige' and 'Online')"
  task :load_regions => [:environment] do

    ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Load Regions') do |log|

      # Populate the 'regions' table for Swedish regions (aka counties),
      # as well as 'Sverige' (Sweden) and 'Online'.  This is used to specify
      # the primary region in which a company operates.
      #
      # This uses the 'city-state' gem for a list of regions (name and ISO code).

      if Region.exists?
        log.record('warn', 'Regions table not empty.')
      else
        CS.states(:se).each_pair { |k, v| Region.create(name: v, code: k.to_s) }
        Region.create(name: 'Sverige', code: nil)
        Region.create(name: 'Online', code: nil)

        log.record('info', "#{Region.count} Regions created.")
      end
    end
  end

  desc "load kommuns data (290 Swedish municipalities)"
  task :load_kommuns => [:environment] do

    require 'csv'
    require 'smarter_csv'

    ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Load Kommuns') do |log|

      if Kommun.exists?
        log.record('warn', 'Kommuns table not empty.')
      else
        SmarterCSV.process('lib/seeds/kommuner.csv').each do |kommun|
          Kommun.create(name: kommun[:name])
        end

        log.record('info', "#{Kommun.count} Kommuns created.")
      end
    end
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

    ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Geocode Addresses') do |log|

      not_geocoded = Address.not_geocoded

      msg = " #{not_geocoded.count} Addresses are not yet geocoded.  Will geocode."
      log.record('info', msg)

      Address.geocode_all_needed(sleep_between: args[:sleep_time].to_f, num_per_batch: args[:batch_num].to_i)

      msg = " After running Address.geocode_all_needed(sleep_between: " +
            "#{args[:sleep_time].to_f}, num_per_batch: #{args[:batch_num].to_i})"+
            ", #{Address.not_geocoded.count} Addresses are not geocoded."
      log.record('info', msg)
    end
  end

  desc 'add member page arg=[filename]'
  task :add_member_page, [:filename] => :environment do |task_name, args|

    ActivityLogger.open(LOG_FILE, 'SHF_TASK', task_name) do |log|

      filename = args.fetch(:filename) do |_key|
        log.record('error', 'You must specify a file name')
        raise 'ERROR: You must specify a file name'
      end

      if filename =~ /[^\w\-\.]/
        log.record('error', "Unacceptable characters in filename: #{filename}")
        log.record('error', "Acceptable characters are a-z, A-Z, 0-9, '_', '-' and '.'")
        raise 'ERROR: Unacceptable filename'
      end

      # Add html file type if not present
      filename = filename + '.html' unless filename =~ /.*\.html$/

      filepath = File.join(Rails.root, 'app', 'views', 'pages', filename)

      unless File.file?(filepath)
        begin
          File.new(filepath, 'w+')
          log.record('info', "Created member page file: #{filename}")
        rescue
          log.record('error', "Cannot create file: #{filename}")
          raise
        end
      else
        log.record('error', 'File already exists in pages directory')
        raise 'ERROR: File already exists in pages directory'
      end
    end
  end


  # -------------------------------------------------

  def database_exists?
    ActiveRecord::Base.connection
  rescue ActiveRecord::NoDatabaseError
    false
  else
    true
  end


  def import_a_member_app_csv(row, log)

    log.record('info', "Importing row: #{row.inspect}")

    # log_and_show log, Logger::INFO, "Importing row: #{row.inspect}"

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

    if (membership = ShfApplication.find_by(user: user.id))
      puts_already_exists('Membership application', " org number: #{row[:company_number]}")
    else
      membership = ShfApplication.create!(company_number: row[:company_number],
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
                      phone_number: phone_number,
                      website: website)

      company = Company.find_by_company_number(company_num)

      company.addresses << Address.new(street_address: street,
                                       post_code: post_code,
                                       city: city,
                                       region: region)

      puts_created 'Company', company.company_number
    end
    company
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
