require 'rails_helper'

require 'shared_context/companies'


RSpec.describe CompanyMetaInfoAdapter do

  include_context 'create companies'

  subject { described_class.new(complete_co1) }


  describe '#title' do

    context 'not blank' do
      it 'is the company name' do
        expect(subject.title).to eq complete_co1.name
      end
    end

    context 'blank' do
      it 'is the Site meta info default for title' do
        blank_name_co = create(:company)
        blank_name_co.name = ''
        expect(described_class.new(blank_name_co).title).to eq SiteMetaInfoDefaults.title
      end
    end
  end


  describe '#description' do

    context 'not blank' do
      it 'is the company name' do
        expect(subject.description).to eq complete_co1.description
      end
    end

    context 'blank' do
      it 'is the Site meta info default for description' do
        blank_name_co = create(:company)
        blank_name_co.description = ''
        expect(described_class.new(blank_name_co).description).to eq SiteMetaInfoDefaults.description
      end
    end
  end


  describe '#keywords' do

    context "not blank" do
      it "business category names joined with ', '" do
        expect(subject.keywords).to eq complete_co1.business_categories.map(&:name).join(', ')
      end
    end

    context 'blank' do
      it 'is the Site meta info default for keywords' do
        blank_name_co = create(:company)
        blank_name_co.business_categories.each{|cat| cat.name = ''}
        expect(described_class.new(blank_name_co).keywords).to eq SiteMetaInfoDefaults.keywords
      end
    end
  end


  describe '#og' do

    it '[:title] is same as #title' do
      expect(subject.title).to eq complete_co1.name
    end

    it '[:description] is same as #description' do
      expect(subject.description).to eq complete_co1.description
    end

  end

end
