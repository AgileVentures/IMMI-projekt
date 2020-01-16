#--------------------------
#
# @class ArrayArraysAsTable
#
# @desc Responsibility: Creates a string with an Array of Arrays of Strings and/or Numbers
#   formatted as a Table.
#  BASED ON print_table FROM THOR: bundler/vendor/thor/lib/thor/shell/basic.rb
#
#  I needed a way to easily view an array of arrays as a decently formatted table.
#  The code in Thor had the basic methods.  I refactored and renamed some things,
#  added the :row_end and :column_separator options,
#  and made the output a String instead of writing to $stdout.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   12/14/19
#
#--------------------------
#
class ArrayArraysAsTable

  DEFAULT_COL_SEPARATOR = '  '
  DEFAULT_ROW_ENDER = $/


  # Prints an Array of Arrays of Strings and/or Numbers as table, returns a String
  # array[0] = column headers
  # array[1] = first row
  # array[2] = second row
  # ...
  # array[n] = nth row
  #
  #
  # @param [Array<Array<String|Number>] array  - array of arrays = the table to print out.  Every entry should be a String or Number
  # @param [Hash] options - options
  #    indent<Integer>:: Indent the first columnof the entire table by indent value.
  #    colwidth<Integer>:: Force the first column to colwidth spaces wide. Ex: if the first column is a label, set this to be plenty wide so all of the data in the following columns is aligned nicely
  #    row_end<String>:: String to use at the end of each row.  Default = "\n"
  #    column_separator<String>:: String to use at the end of each column. Default = "  " (2 spaces)
  #
  # @return [String]  - a String with the formatted table
  def self.print_table(array, options = {}) # rubocop:disable MethodLength
    return if array.empty?

    set_options(options)

    result = ''
    maxs_and_formats = column_max_lengths_formats(array, @first_colwidth, @indent)
    result << puts_rows(array, maxs_and_formats[:col_maximas], maxs_and_formats[:formats])
    result
  end


  def self.set_options(options)
    @indent = options[:indent].to_i
    @first_colwidth = options[:colwidth]
    @row_ender = options.fetch(:row_end, DEFAULT_ROW_ENDER)
    @col_separator = options.fetch(:column_separator, DEFAULT_COL_SEPARATOR)
  end


  def self.column_max_lengths_formats(array, first_colwidth, indent)
    col_maximas = []
    formats = []
    formats << "%-#{first_colwidth}s#{@col_separator}".dup if first_colwidth

    start = first_colwidth ? 1 : 0
    colcount = array.max { |arr_a, arr_b| arr_a.size <=> arr_b.size }.size - 1

    # Create maxima (max. col. length) and format for each column
    start.upto(colcount) do |column_index|
      col_max_size = col_max_size(array, column_index)
      col_maximas << col_max_size

      # Don't append the @col_separator when printing the last column
      formats << ((column_index == colcount) ? col_str_format : col_padded_str_format(col_max_size))
    end
    formats << "%s" # format for last column
    formats[0] = formats[0].insert(0, ' ' * indent) # indent the first column by 'indent' spaces

    return { col_maximas: col_maximas, formats: formats }
  end


  # get the size of the widest string in the column
  def self.col_max_size(array, column_index)
    array.map { |row| row[column_index] ? row[column_index].to_s.size : 0 }.max # rubocop:disable DuplicateMethodCall
  end


  def self.puts_rows(array, maximas, formats)
    array.map { |row| row_sentence(row, maximas, formats) }.join('')
  end


  def self.row_sentence(row, maximas, formats)
    row_sentence = ''.dup
    row.each_with_index do |column, index|
      format_str = column.is_a?(Numeric) ?
          formatted_numeric_col(index, row.size, maximas[index]) :
          formats[index]

      # apply the format string (format_str) to the column value (as a String)
      row_sentence << format_str % column.to_s
    end
    row_sentence << @row_ender.dup
  end


  def self.col_str_format
    '%-s'.dup
  end


  def self.col_padded_str_format(padding = 3)
    "%-#{padding}s#{@col_separator}".dup
  end


  def self.formatted_numeric_col(index, row_size, max_length)
    # Don't output @col_separator at the end of a column when printing the last column
    (index == row_size - 1) ? numeric_base_col_format(max_length) : numeric_col_format_not_last(max_length)
  end


  # append the column separator to the formatted column
  def self.numeric_col_format_not_last(max_length)
    "#{numeric_base_col_format(max_length)}#{@col_separator}"
  end


  def self.numeric_base_col_format(max_length)
    "%#{max_length}s"
  end
end
