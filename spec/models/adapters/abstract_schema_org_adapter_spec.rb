require 'rails_helper'


class TestAdapter < Adapters::AbstractSchemaOrgAdapter

  # create a class that is 'adapted'
  class FauxSchemaOrgClass

    def to_ld_json
      "to_ld_json #{to_json}"
    end


    def to_json(as_root: true)
      if as_root
        { 'root':    true,
          'to_json': to_json_struct }
      else
        { 'to_json': to_json_struct }
      end

    end


    def to_json_struct
      { '@type': 'some type',
        'key':   'value'
      }
    end


    # This just contrived for this test
    def ==(something)
      something.class == self.class &&
          something.to_ld_json == self.to_ld_json
    end

  end # end faux class


  def target_class
    FauxSchemaOrgClass
  end


  def set_target_attributes(target)
    target
  end
end


class TestSublcassMissingMethodsAdapter < Adapters::AbstractSchemaOrgAdapter
end


RSpec.describe Adapters::AbstractSchemaOrgAdapter, type: :model do

  let(:test_adapter) { TestAdapter.new('some string') }
  let(:as_target_result) { test_adapter.as_target }

  let(:test_bad_adapter) { TestSublcassMissingMethodsAdapter.new('some string') }


  it 'adapter cannot be nil' do
    expect { TestAdapter.new(nil) }.to raise_exception ArgumentError
    expect(TestAdapter.new('some string')).to be_a(TestAdapter)
  end


  describe 'target_class' do

    it "subclasses must implement; raises NoMethodError if they don't" do
      expect { test_bad_adapter.target_class }.to raise_exception NoMethodError
    end

  end

  describe 'set_target_attributes' do

    it "subclasses must implement; raises NoMethodError if they don't" do
      expect { test_bad_adapter.set_target_attributes('blorf') }.to raise_exception NoMethodError
    end
  end


  describe 'as_target' do

    it 'calls target_class' do
      expect(test_adapter).to receive(:target_class)
                                  .and_call_original
      test_adapter.as_target
    end


    it 'calls set_target_attributes with an instance of the target_class' do
      expect(test_adapter).to receive(:set_target_attributes)
                                  .with(kind_of(test_adapter.target_class))
                                  .and_call_original
      test_adapter.as_target
    end


    describe 'returns the target, which must respond to:' do

      it 'to_ld_json' do
        expect(as_target_result.to_ld_json).to eq('to_ld_json ' +
                                                      { root:    true,
                                                           to_json: { '@type': 'some type', key: 'value' }
                                                      }.to_s)
      end

      it 'to_json(as_root:)' do
        expect(as_target_result.to_json).to eq({ root: true,
                                                 to_json:
                                                       { '@type': 'some type', key: 'value' }
                                               })

        expect(as_target_result.to_json(as_root: true)).to eq({ root: true,
                                                                to_json:
                                                                      { '@type': 'some type', key: 'value' }
                                                              })

        expect(as_target_result.to_json(as_root: false)).to eq({ to_json:
                                                                     { '@type': 'some type', key: 'value' }
                                                               })
      end

      it 'to_json_struct' do
        expect(as_target_result.to_json_struct).to eq({ '@type': 'some type', key: 'value' })
      end

    end

  end


  describe 'as_target aliases for readability' do

    it 'to_schema_org' do
      expect(test_adapter.to_schema_org).to eq as_target_result
    end

    it 'to_target' do
      expect(test_adapter.to_target).to eq as_target_result
    end
  end


end
