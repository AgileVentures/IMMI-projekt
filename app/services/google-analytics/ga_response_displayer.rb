require 'google/apis/analyticsreporting_v4'
require_relative File.join(__dir__, 'array_arrays_as_table')

#--------------------------
#
# @class GAResponseDisplayer
#
# @desc Responsibility: Display a Google::Apis::AnalyticsreportingV4::GetReportsResponse in a readable form
#
# @example
#   # Assume that the list of reports is fetched.  This example uses GAExplorer to get reports
#   fetched_ga_reports =  GAExplorer.get_reports # Gets SHF company page hits for the last 30 days
#   puts GAResponseDisplayer.response_reports_as_tables
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   12/14/19
#
#--------------------------
#
class GAResponseDisplayer

  ANALYTICS4 = Google::Apis::AnalyticsreportingV4 # short alias for the Analytics  module

  # Format each report in the response as a simple table.
  #
  # @return [String] - reports formatted as simple tables, each separated by 2 blank lines (\n\n)
  def self.response_reports_as_tables(response = ANALYTICS4::GetReportsResponse.new)
    response.reports.map { |report| "#{report_as_table(report)}\n\n" }.join('')
  end


  # Format the report as a table.  Append simple totals at the bottom
  #
  # @return [String] - the formatted info
  def self.report_as_table(report)
    data = report.data
    rows = data.rows

    max_dim_name_length = max_dimension_name_length(rows)
    col_heads = column_headers(report.column_header)

    rows_and_cols_as_table(rows, col_heads, max_dim_name_length) +
        totals_as_columns(data.totals, col_heads, max_dim_name_length) +
        "  #{data.row_count} rows\n"
  end


  # @return [Array<String>] - array of Strings that form the column headers
  # TODO This only prints out the first dimension.  If there are multiple dimensions, it won't print them.
  def self.column_headers(report_column_header)

    dimension_headers = report_column_header.dimensions
    metric_header = report_column_header.metric_header
    metric_headers = metric_header.metric_header_entries
    pivot_col_heads = pivot_col_headers(metric_header.pivot_headers)

    [[dimension_headers.first] + metric_headers.map(&:name) + pivot_col_heads.flatten]
  end


  def self.max_dimension_name_length(rows)
    # rubocop:disable UncommunicativeVariableName
    rows.map { |row| row.dimensions }.flatten.max { |dimension_a, dimension_b| dimension_a.length <=> dimension_b.length }.length
  end


  # @return [String] - rows and column headers formatting as a table
  def self.rows_and_cols_as_table(rows, col_heads, max_row_dimension_length = 0)
    rows_as_arrays = rows.map { |row| report_row_to_a(row) }
    ArrayArraysAsTable.print_table(col_heads + rows_as_arrays, colwidth: max_row_dimension_length)
  end


  # @return [String] - a separator line ('-----') followed by the totals, formatted in columns
  def self.totals_as_columns(totals, col_heads, max_row_dimension_length = 0)
    total_rows = []
    totals.each do |data_total|
      total_rows << ['TOTAL '.ljust(max_row_dimension_length)].concat(date_range_value_to_a(data_total))
    end

    total_separator(max_row_dimension_length) +
        ArrayArraysAsTable.print_table(col_heads + total_rows, colwidth: max_row_dimension_length)
  end


  #  Could use map, but it looses some readability
  def self.pivot_col_headers(pivot_headers)
    pivot_col_heads = []
    pivot_headers.each { |pivot_header| pivot_col_heads << pivot_header.pivot_header_entries.map(&:dimension_values).flatten }
    pivot_col_heads
  end


  # Return the report row as an array. Dimension name = array[0] and values[0..n] are array entries [1.. n+1]
  # Every entry in the Array is a String
  #
  # @return [Array<String>] - array of Strings
  def self.report_row_to_a(report_row, max_row_dim_length: 0)

    row_dimensions = report_row.dimensions
    row_metrics = report_row.metrics

    row_dimensions.map do |row_dimension|
      dimension_with_metrics_to_a(row_dimension.ljust(max_row_dim_length), row_metrics)
    end.flatten
  end


  # Array with the row dimension, followed by the metric values
  #  Could use map, but it looses some readability:
  #    row_metrics.map{ | date_range_value | [row_dimension_value] + date_range_value_to_a(date_range_value) }.flatten
  def self.dimension_with_metrics_to_a(row_dimension_value, row_metrics)
    dim_metrics = []
    row_metrics.each do |date_range_value|
      dim_metrics << row_dimension_value
      dim_metrics.concat(date_range_value_to_a(date_range_value))
    end
    dim_metrics
  end


  def self.date_range_value_to_a(date_range_value)
    [].concat(date_range_value.values).concat(date_range_value.pivot_value_regions.map(&:values).flatten)
  end


  def self.total_separator(max_col_length)
    # Arbitrarily adding 14 more dashes to make the line longer
    # TODO make this a constant; don't make it arbitrary
    '-' * (max_col_length + 14) + "\n"
  end

end
