require 'rails_helper'

# RSpec specification for a class with the 'updated_in_date_range' scope (class method)
#
# Pass in the method (symbol) that FactoryBot should use to create an instance of the class
# Ex:
#   To test the Payment class, assuming there is a factory method ':payment', you would say:
#    it_behaves_like 'it_has_updated_in_date_range_scope', :payment
#
#   Note the Factory must have  updated_at as an attribute that can be set
RSpec.shared_examples 'it_has_updated_in_date_range_scope' do | factory_method |


  let!(:start_date)        { Time.zone.local(2018, 01, 01, 00, 00, 00) }
  let!(:before_start_date) { Time.zone.local(2017, 12, 31, 23, 59, 59) }
  let!(:after_start_date)  { Time.zone.local(2018, 01, 01, 00, 00, 01) }

  let!(:end_date)          { Time.zone.local(2018, 02, 01, 00, 00, 00) }
  let!(:before_end_date)   { Time.zone.local(2018, 01, 31, 23, 59, 59) }
  let!(:after_end_date)    { Time.zone.local(2018, 02, 01, 00, 00, 01) }

  let(:updated_before_start_date) { create(factory_method, updated_at: before_start_date) }
  let(:updated_on_start_date)     { create(factory_method, updated_at: start_date) }
  let(:updated_after_start_date)  { create(factory_method, updated_at: after_start_date) }

  let(:updated_before_end_date)   { create(factory_method, updated_at: before_end_date) }
  let(:updated_on_end_date)       { create(factory_method, updated_at: end_date) }
  let(:updated_after_end_date)    { create(factory_method, updated_at: after_end_date) }


  it 'returns all payments updated on the start_date' do
    updated_on_start_date
    expect(described_class.updated_in_date_range(start_date, end_date)).to include(updated_on_start_date)
  end

  it 'returns all payments updated on the end_date' do
    updated_on_end_date
    expect(described_class.updated_in_date_range(start_date, end_date)).to include(updated_on_end_date)
  end

  it 'returns all payments updated between start_date and end_date' do
    updated_after_start_date
    updated_before_end_date
    expect(described_class.updated_in_date_range(start_date, end_date)).to include(updated_after_start_date, updated_before_end_date)
  end

  it 'does not return payments updated before the start_date' do
    updated_before_start_date
    expect(described_class.updated_in_date_range(start_date, end_date)).not_to include(updated_before_start_date)
  end

  it 'does not return payments updated after the end_date' do
    updated_after_end_date
    expect(described_class.updated_in_date_range(start_date, end_date)).not_to include(updated_after_end_date)
  end

  context 'invalid arguments' do
    it 'raises exception if start_date is nil: ArgumentError: bad value for range' do
      expect{described_class.updated_in_date_range(nil, end_date)}.to raise_exception ArgumentError, 'bad value for range'
    end

    it 'raises exception if end_date is nil: ArgumentError: bad value for range' do
      expect{described_class.updated_in_date_range(start_date, nil)}.to raise_exception ArgumentError, 'bad value for range'
    end

    it 'raises exception if start_date is not a date: ArgumentError: bad value for range' do
      expect{described_class.updated_in_date_range(99, end_date)}.to raise_exception ArgumentError, 'bad value for range'
    end


    it 'causes a SQL error if start_date is a date exception and end_date a number:' do
      # the SQL statement is only executed if it has a .count or other method chained after it.  That's why .count is included below
      expect{ described_class.updated_in_date_range(start_date, 99).count }.to raise_error ActiveRecord::StatementInvalid
    end

    it 'raises exception if end_date is not a date or a Number: ArgumentError: bad value for range' do
      expect{described_class.updated_in_date_range(start_date, Class)}.to raise_exception ArgumentError, 'bad value for range'
    end
  end


end
