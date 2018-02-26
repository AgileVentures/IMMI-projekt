module AdminOnly

#--------------------------
#
# @class DataGatherer
#
# @desc Responsibility: Gather information from the data for summary and analysis
#          Answer basic questions like "how many..."  ... over some timeframe... etc
#
#          A simple PORO that gathers information from the data
#          and stores any constants required to do so.
#         (Perhaps one day the constants will become configuration options.)
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   1/1/18
#
# @file data_gatherer.rb
#
#--------------------------

  class DataGatherer


    # standard days_ago_list in days
    TIMEFRAMES = [7, 14, 30, 90, 120, 180, 270, 366].freeze

    DEFAULT_NUM_PAST_DAYS = TIMEFRAMES.first

    PAYMENT_TYPES = [Payment::PAYMENT_TYPE_MEMBER, Payment::PAYMENT_TYPE_BRANDING]


    # Read-only (info comes from the db)
    attr :total_members,
         :total_companies,
         :total_users,
         :app_states_translated,
         :shf_apps_state_counts,
         :apps_without_uploads,
         :apps_approved_member_fee_not_paid,
         :companies_branding_not_paid,
         :companies_info_not_completed,
         :recent_shf_apps,
         :translated_users,
         :recent_app_state_counts,
         :recent_payments


    # load the data
    def initialize

      @timeframe = DEFAULT_NUM_PAST_DAYS
      @shf_apps_state_counts = {}
      @recent_shf_apps = []
      @recent_app_state_counts = {}
      @recent_payments = initialize_recent_payments

      refresh_data
    end


    #
    # update recent data: fetch from the db and update all the relate instance variables
    #  default is the past DEFAULT_NUM_PAST_DAYS days
    #
    def get_recent_data(timeframe_start = (Time.zone.now - DEFAULT_NUM_PAST_DAYS.days), timeframe_end =  Time.zone.now)

      get_recent_shf_apps(timeframe_start, timeframe_end)
      get_recent_financial_info(timeframe_start, timeframe_end)

    end


    def timeframe
      @timeframe ||= DEFAULT_NUM_PAST_DAYS
    end

    # can only set the timeframe to a value that is in our days_ago_list
    # if val is not in days_ago_list, raise_exception ''
    def timeframe=(val)
      raise(ArgumentError, 'timeframe value must be in the days_ago_list') unless days_ago_list.include? val

      @timeframe = val
      refresh_data

    end

    def days_ago_list
      TIMEFRAMES
    end


    # ----------------

    private

    # Reload all data from the database
    # This does *not* change the timeframe
    #
    def refresh_data
      @total_companies = Company.all.count


      # membership applications by state
      ShfApplication.all_states.each do |app_state|
        shf_apps_state_counts[app_state] = ShfApplication.total_in_state app_state
      end
      @app_states_translated = ShfApplication.group(:state).count.transform_keys {
          |k| I18n.t "activerecord.attributes.shf_application.state/#{k}"
      }
      @apps_without_uploads = ShfApplication.no_uploaded_files
      @apps_approved_member_fee_not_paid = User.all.select(&:member_fee_payment_due?)

      @companies_branding_not_paid = Company.all.reject(&:branding_license?)
      @companies_info_not_completed = Company.all - Company.complete

      @total_users = User.all.count
      @total_members = User.members.count

      @translated_users = User.group(:member).count.transform_keys {
          |k| I18n.t "activerecord.attributes.member.#{k}"
      }

      get_data_for_past_days(timeframe)

    end


    def initialize_recent_payments
      @recent_payments = {}
      PAYMENT_TYPES.each { |payment_type| @recent_payments[payment_type.to_sym] = [] }
      @recent_payments
    end


    # load data from the db for the past recent_number_of_days days (including today)
    #   default number of days to display = 7
    #
    def get_data_for_past_days(recent_number_of_days = DEFAULT_NUM_PAST_DAYS)

      daterange_end = Time.zone.now

      get_recent_data(daterange_end - recent_number_of_days.days, daterange_end)
    end


    # get recent SHF Applications from the db for the current timeframe
    # and set the instance variables for it
    def get_recent_shf_apps(start_date, end_date)

      @recent_shf_apps = ShfApplication.updated_in_date_range(start_date, end_date)

      unless @recent_shf_apps.empty?
        ShfApplication.all_states.each do |app_state|
          recent_app_state_counts[app_state] = @recent_shf_apps.where(state: app_state).count
        end
      end

      @recent_shf_apps   # return this to make testing easier
    end


    # get recent financial info from the db for the current timeframe and set the instance variables for it
    def get_recent_financial_info(start_date, end_date)
      recent_payments[Payment::PAYMENT_TYPE_MEMBER.to_sym] = Payment.member_fee.updated_in_date_range(start_date, end_date) # Payment.member_fee.where(status: 'betald', updated_at: start_date..end_date)
      recent_payments[Payment::PAYMENT_TYPE_BRANDING.to_sym] = Payment.branding_fee.updated_in_date_range(start_date, end_date) # where(status: 'betald', updated_at: start_date..end_date)

      recent_payments  # return this to make testing easier
    end


  end # DataGatherer

end # module AdminOnly
