require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#flash_class' do

    it 'adds correct class on notice' do
      expect(helper.flash_class(:notice)).to eq 'success'
    end

    it 'adds correct class on alert' do
      expect(helper.flash_class(:alert)).to eq 'danger'
    end
  end
end
