# frozen_string_literal: true

require 'rails_helper'

require 'orgnummer'

describe OrgNummersGenerator do
  describe '#generate( number_to_generate )' do
    it 'number to generate default== 1' do
      generated = described_class.generate
      expect(generated).to be_a Set
      expect(generated.count).to eq 1
    end

    describe 'returns a Set of (frozen) strings; empty if number requests is <= 0' do
      it 'generate(-1) is empty' do
        generated = described_class.generate(-1)
        expect(generated).to be_a Set
        expect(generated).to be_empty
      end

      it 'generate(0) is empty' do
        generated = described_class.generate(0)
        expect(generated).to be_a Set
        expect(generated).to be_empty
      end

      it 'generate(2)' do
        generated = described_class.generate(2)
        expect(generated).to be_a Set
        expect(generated.count).to eq 2
      end
    end
  end

  describe '#generate_one' do
    describe 'always returns just 1 String or nil (if no valid org number could be generated with the parameters)' do
      it 'returns a single string org nummer by default' do
        expect(described_class.generate_one).to be_a String
      end
    end

    it 'is valid according to the orgnummber gem' do
      20.times do
        expect(Orgnummer.new(described_class.generate_one).valid?).to be_truthy
      end
    end

    it 'org number string is always 10 digits (\d\d\d\d\d\d\d\d\d\d) that may be left-padded with zeros' do
      20.times do
        expect(described_class.generate_one).to match(/\d\d\d\d\d\d\d\d\d\d/)
      end
    end
  end
end
