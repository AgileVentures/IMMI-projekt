require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'flashes' do
    it 'adds correct class on notice' do
      expect(helper.flash_class(:notice)).to eql('success')
    end
    it 'adds correct class on alert' do
      expect(helper.flash_class(:alert)).to eql('danger')
    end
  end
end
