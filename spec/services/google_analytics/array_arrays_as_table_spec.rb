require 'spec_helper'

require File.join(__dir__, '..', '..', '..', 'app/services/google-analytics/array_arrays_as_table')

# Yes, this 'over tests' ArrayArraysAsTable


RSpec.describe ArrayArraysAsTable do


  def make_col_headers(columns: 0)
    column_headers = []
    columns.times { |col| column_headers << "column_#{col}" }
    column_headers
  end


  def entry_string(row, col)
    "row#{row}_col#{col}"
  end


  def make_nested_arrays(columns: 0, rows: 0)
    nested_array = []

    nested_array << make_col_headers(columns: columns)
    rows.times do |row|
      this_row = []
      columns.times { |col| this_row << yield(row, col) }
      nested_array << this_row
    end

    nested_array
  end


  def make_string_nested_arrays(columns: 0, rows: 0)
    make_string_entries_method = lambda { |row, col| "row#{row}_col#{col}" }
    make_nested_arrays(columns: columns, rows: rows, &make_string_entries_method)
  end


  def make_numeric_nested_arrays(columns: 0, rows: 0)
    make_numeric_entries_method = lambda { |row, col| row * col }
    make_nested_arrays(columns: columns, rows: rows, &make_numeric_entries_method)
  end


  # -----------------------------------------------------------------------


  describe 'print_table' do

    let(:array_3x4) { make_string_nested_arrays(columns: 3, rows: 4) }
    let(:default_result) { described_class.print_table(array_3x4) }


    it 'creates a String with the output' do
      expected_3x4 = "column_0   column_1   column_2\nrow0_col0  row0_col1  row0_col2\nrow1_col0  row1_col1  row1_col2\nrow2_col0  row2_col1  row2_col2\nrow3_col0  row3_col1  row3_col2\n"
      expect(default_result).to be_a String
      expect(default_result).to eq expected_3x4
    end

    it 'number of rows = 1(for column headers) + rows' do
      expect(default_result.lines.size).to eq 5
    end

    it 'each sub array (each single row) size = number of columns' do
      expect(default_result.lines.map { |row| row.split(' ').size }).to eq [3, 3, 3, 3, 3]
    end

    it 'columns are padded with blanks so they are the width of the widest string in that column (including column headers)' do

      array_2x11 = make_string_nested_arrays(columns: 2, rows: 11)
      comma_sep_cols_semicolon_row_ends = described_class.print_table(array_2x11, { column_separator: ',', row_end: ';' })

      rows = comma_sep_cols_semicolon_row_ends.lines(';')
      first_cols = rows.map { |row| row.lines(',').first }

      # The first 10 columns are padded by 1 space (they are col_0 .. col9).
      # remove the trailing comma from each (left on there from the call to .lines)
      10.times do |n|
        without_comma = first_cols[n - 1].delete_suffix(',')
        expect(without_comma.lstrip.size).to eq(first_cols[n - 1].size - 1)
      end

      # The last column is the widest, so it has no padding
      last_col_without_comma = first_cols.last.delete_suffix(',')
      expect(last_col_without_comma.lstrip.size).to eq(last_col_without_comma.size)
    end


    describe 'can handle arrays with numbers (instead of Strings)' do

      let(:numeric_4x3) { make_numeric_nested_arrays(columns: 4, rows: 3) }

      it 'can handle arrays with numbers (instead of Strings)' do
        expected_numeric_4x3 = "column_0,column_1,column_2,column_3\n       0,       0,       0,       0\n       0,       1,       2,       3\n       0,       2,       4,       6\n"
        expect(described_class.print_table(numeric_4x3, column_separator: ',')).to eq expected_numeric_4x3
      end


      it 'numbers are padded to the widest entry in the column (including the width of the column header)' do

        result = described_class.print_table(numeric_4x3, column_separator: ',')

        rows = result.lines
        (rows.size - 1).times do |row_num|
          row = rows[row_num + 1]
          cols = row.lines(',')

          cols.each do |column|
            # Each numeric column has just 1 digit. They are padded with 7 spaces on the left (prefixed) to match the width of the widest entry in the column (the column header)
            expect(column.lstrip.size + 7).to eq(column.size)
          end
        end
      end

    end

    describe 'options' do

      describe ':indent - number of spaces to indent the table' do

        let(:expected_indent_4_spaces) { "    column_0   column_1   column_2\n    row0_col0  row0_col1  row0_col2\n    row1_col0  row1_col1  row1_col2\n    row2_col0  row2_col1  row2_col2\n    row3_col0  row3_col1  row3_col2\n" }

        it 'default is 0' do
          rows = default_result.lines
          first_cols = rows.map { |row| row.lines(',').first }
          first_cols.each do |first_column|
            expect(first_column.lstrip.size).to eq(first_column.size)
          end
        end

        it 'specify the number of spaces to indent' do
          indent_4_spaces = described_class.print_table(array_3x4, indent: 4, column_separator: ',')
          rows = indent_4_spaces.lines
          first_cols = rows.map { |row| row.lines(',').first }

          first_cols.each do |first_column|
            expect(first_column.lstrip.size).to eq(first_column.size - 4)
          end

          expected_result = "    column_0 ,column_1 ,column_2\n    row0_col0,row0_col1,row0_col2\n    row1_col0,row1_col1,row1_col2\n    row2_col0,row2_col1,row2_col2\n    row3_col0,row3_col1,row3_col2\n"
          expect(indent_4_spaces).to eq expected_result
        end
      end

      describe ':first_colwidth - the width of the first column, which is often a row label' do

        let(:expected_firstwidth_12) { "column_0    ,column_1 ,column_2\nrow0_col0   ,row0_col1,row0_col2\nrow1_col0   ,row1_col1,row1_col2\nrow2_col0   ,row2_col1,row2_col2\nrow3_col0   ,row3_col1,row3_col2\n" }


        it 'default is none, which sets the width just like all the other columns' do
          default_first_width = described_class.print_table(array_3x4, column_separator: ',')
          rows = default_first_width.lines
          default_col_widths = rows.map { |row| row.lines(',').first.size }
          expect(default_col_widths).to eq [10, 10, 10, 10, 10] # 9 + 1 (9 = the width of the widest string in the column; + 1 because the split will include the comma)
        end

        it 'sets the width for the first column (often is row labels)' do
          first_width_12 = described_class.print_table(array_3x4, colwidth: 12, column_separator: ',')
          rows = first_width_12.lines
          first_col_widths = rows.map { |row| row.lines(',').first.size }

          expect(first_col_widths).to eq [13, 13, 13, 13, 13] # 12 + 1 (+ 1 because the split will include the comma)
          expect(first_width_12).to eq expected_firstwidth_12
        end
      end


      describe ':row_end - can specify the string to append to the end of each row' do

        it 'default is \n' do
          expect(default_result.split("\n").size).to eq 5
        end

        it 'specify a row ending' do
          expected_3x4_row_end_semicolons = "column_0   column_1   column_2;row0_col0  row0_col1  row0_col2;row1_col0  row1_col1  row1_col2;row2_col0  row2_col1  row2_col2;row3_col0  row3_col1  row3_col2;"

          rows_end_with_semicolon = described_class.print_table(array_3x4, row_end: ';')
          expect(rows_end_with_semicolon.lines.size).to eq 1 # just the one whole string, not split by any line endings
          expect(rows_end_with_semicolon.lines(";").size).to eq 5
          expect(rows_end_with_semicolon).to eq expected_3x4_row_end_semicolons
        end
      end


      describe ':column_separator - can specify the String to append to the end of each column (a column separator)' do

        it 'default is 2 spaces' do
          expect(default_result.lines('  ').size).to eq((4 * 3) - 1)
        end

        it 'specify a column separator (comma and space)' do
          expected_3x4_column_separator_comma = "column_0 ,column_1 ,column_2\nrow0_col0,row0_col1,row0_col2\nrow1_col0,row1_col1,row1_col2\nrow2_col0,row2_col1,row2_col2\nrow3_col0,row3_col1,row3_col2\n"


          cols_separated_with_comma = described_class.print_table(array_3x4, column_separator: ',')
          expect(cols_separated_with_comma.lines(',').size).to eq((4 * 3) - 1)
          expect(cols_separated_with_comma).to eq expected_3x4_column_separator_comma
        end
      end
    end

  end


end
