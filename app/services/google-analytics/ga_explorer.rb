require 'googleauth'
require 'google/apis/analyticsreporting_v4'


#--------------------------
#
# @class GAExplorer
#
# @desc Responsibility: Fetch and explore data from Google Analytics. Expects
#  the credentials to be in the JSON file identified by JSON_SECRETS_FILE.
#  (Currently this class reads the file name from ENV.)
#
# @example
#    fetched_ga_reports =  GAExplorer.get_reports # Gets the default data: company page hits for the last 30 days
#
#
# Google API Analytics classes: @see google-api-client-0.36.0/generated/google/apis/analyticsreporting_v4/classes.rb
#
# Helpful code:
# @see https://medium.com/fiatinsight/using-the-google-analytics-reporting-api-v4-with-rails-8d3c2f689807
# @see https://gist.github.com/CoryFoy/9edf1e039e174c00c209e930a1720ce0
#
# Definitions of API Analytics classes _and_ parameters and eums
# @see https://www.any-api.com/googleapis_com/analyticsreporting/docs/Definitions
#   Ex: DimensionFilterClause
#   @see https://www.any-api.com/googleapis_com/analyticsreporting/docs/Definitions/DimensionFilterClause
#
#
# Can use GAResponseDisplayer to display the response as a table.
# Ex:
#   fetched_ga_reports = GAExplorer.get_reports
#   GAResponseDisplayer.response_reports_as_tables(fetched_ga_reports)
#
#
# @authors Herman Lule (Luleherll @ github) and Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   12/12/19
#
#--------------------------
#
class GAExplorer

  ANALYTICS4 = Google::Apis::AnalyticsreportingV4 # short alias for the Analytics module

  SCOPE = ANALYTICS4::AUTH_ANALYTICS_READONLY.freeze
  JSON_SECRETS_FILE = File.join(Rails.root, ENV['SHF_GOOGLE_APPLICATION_CREDENTIALS_FILE'])

  GA_PAGE_PATH = 'ga:pagePath'
  GA_PAGE_VIEWS = 'ga:pageviews'
  GA_COUNTRY_ISOCODE = 'ga:countryIsoCode'

  COMPANIY_PAGES_REGEXP = '/hundforetag/[^/]*$'.freeze

  # -------------------------------------------------------------------------


  # Get data from Google Analytics for company page hits for the last 30 days
  #
  # @return [Array<Google::Apis::AnalyticsreportingV4::Report>] - the reports with the data.
  # (Will have just 1 report based on the request made.)
  def self.get_reports
    analytics = authorized_analytics
    analytics.batch_get_reports(build_request_with(:company_page_hits_30d))
  end


  # Create the Hash parameters for a ReportRequest by calling the report_info_method
  #
  # @param [Symbol] report_info_method - the method to call to create the Hash.  Default = :company_page_hits_30d
  # @param [Array<Google::Apis::AnalyticsreportingV4::DateRange>] date_ranges - the date ranges for the report.  Default = [Google::Apis::AnalyticsreportingV4::DateRange.new(start_date: '30DaysAgo', end_date: 'today')]
  #
  # @return [Google::Apis::AnalyticsreportingV4::GetReportsRequest] - a report request with the single report request constructed with the :report_info_method for the date ranges :date_ranges
  #
  def self.build_request_with(report_info_method = :company_page_hits_30d,
                              date_ranges: [date_range_days_ago(30)])

    report_info = { view_id: ENV['SHF_GOOGLE_ANALYTICS_VIEW_ID'],
                    date_ranges: date_ranges,
    }.merge(send report_info_method.to_sym)

    ANALYTICS4::GetReportsRequest.new(
        report_requests: [ANALYTICS4::ReportRequest.new(report_info)]
    )
  end


  # @return [Google::Apis::AnalyticsreportingV4::AnalyticsReportingService] - the analytics service, authorized with the credentials from the JSON Google credentials file
  def self.authorized_analytics
    credentials = Google::Auth::ServiceAccountCredentials.make_creds({ json_key_io: File.open(JSON_SECRETS_FILE), scope: SCOPE })

    analytics = ANALYTICS4::AnalyticsReportingService.new
    analytics.authorization = credentials
    analytics
  end


  # Create the report_info Hash for a ReportRequest that will return
  #  a page page dimension, with the pageViews metric for it,
  #  for the past 30 days, ordered (sorted) by the page path.
  #  This also includes a pivot (= a 2nd metric to apply to the dimension)
  #  for the pageViews by the country ISO code. This will help see which
  #  page views are coming from countries that are meaningful, and what are cruft.
  #
  # @return [Hash] - a hash with :metrics, :dimensions, :dimensionFilterClauses, :order_bys
  def self.company_page_hits_30d

    return { dimensions: [page_path_dimension],
             dimension_filter_clauses: [dim_filter_company_pages],
             metrics: [page_views_metric],
             pivots: [iso_country_pivot],
             order_bys: [ANALYTICS4::OrderBy.new(field_name: GA_PAGE_PATH)]
    }
  end


  #  'dimension' is the list of rows in a table of info returned
  # @return Google::Apis::AnalyticsreportingV4::Dimension for page paths
  def self.page_path_dimension
    ANALYTICS4::Dimension.new(name: GA_PAGE_PATH)
  end


  # A Dimension Filter that will get
  # all pages that match the RegularExpression '/hundforetag/[^/]*$']
  # This will match pages that end with /hundforetag/<something>
  # Ex:
  #    /hundforetag/100
  #    /en/hundforetag/100
  #    /sv/hundforetag/100
  #    /hundforetag/100?fbxxx-zzzzzzzzz
  #
  # @return [Google::Apis::AnalyticsreportingV4::DimensionFilter] - the DimensionFilter with the regular expression for company pages
  def self.dim_filter_company_pages
    dim_filters = [
        ANALYTICS4::DimensionFilter.new(dimension_name: GA_PAGE_PATH,
                                        operator: 'REGEXP',
                                        expressions: [COMPANIY_PAGES_REGEXP])
    ]
    ANALYTICS4::DimensionFilterClause.new(filters: dim_filters)
  end


  # 'metric' is the 'columns' in a table of info returned
  # # @return Google::Apis::AnalyticsreportingV4::Metric for page views
  def self.page_views_metric
    ANALYTICS4::Metric.new(expression: GA_PAGE_VIEWS)
  end


  # @return Google::Apis::AnalyticsreportingV4::Pivot on the country dimension with the page_view_metric metric
  def self.iso_country_pivot
    ANALYTICS4::Pivot.new(dimensions: [country_dimension], metrics: [page_views_metric])
  end


  #  'dimension' is the list of rows in a table of info returned
  # @return Google::Apis::AnalyticsreportingV4::Dimension for country ISO codes
  def self.country_dimension
    ANALYTICS4::Dimension.new(name: GA_COUNTRY_ISOCODE)
  end


  # return a DateRange that is :days_ago from today
  #       @see https://developers.google.com/analytics/devguides/reporting/core/v3/reference#startDate
  #        Date values can be for a specific date by using the pattern YYYY-MM-DD
  #        or relative by using today, yesterday, or the NdaysAgo pattern.
  #        Values must match [0-9]{4}-[0-9]{2}-[0-9]{2}|today|yesterday|[0-9]+(daysAgo).
  #
  # @param [Integer] days_ago - the number of days ago for the start of the date range (relative to today). Default is 30
  # @param [Integer] start_days_ago - the number of days ago for the ned of the date range (relative to today). Default is 0 (= today)
  # @return [Google::Apis::AnalyticsreportingV4::DateRange] - a date range that is :days_ago relative to 'today' (= '0DaysAgo')
  #

  def self.date_range_days_ago(days_ago = 30, start_days_ago = 0)
    ANALYTICS4::DateRange.new(start_date: "#{days_ago.to_i}DaysAgo", end_date: "#{start_days_ago.to_i}DaysAgo")
  end

end
