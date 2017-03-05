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

  describe '#flash_message and #render_flash_message' do

    before(:each) do
      @flash_type = :blorf
      @first_message = 'first_message'
      @second_message = 'second_message'
      flash[@flash_type] = nil
      helper.flash_message @flash_type, @first_message
    end

    describe 'adds message to nil flash[type]' do
      it { expect(flash[@flash_type].count).to eq 1 }
      it { expect(flash[@flash_type].first).to eq @first_message }
      it { expect(helper.render_flash_message(flash[@flash_type])).to eq @first_message }
    end


    describe 'adds message to a flash[type] that already has messages' do

      before (:each) do
        helper.flash_message @flash_type, @second_message
      end

      it { expect(flash[@flash_type].count).to eq 2 }
      it { expect(flash[@flash_type].first).to eq @first_message }
      it { expect(flash[@flash_type].last).to eq @second_message }
      it { expect(flash[@flash_type]).to eq [@first_message, @second_message] }
      it { expect(helper.render_flash_message(flash[@flash_type])).to eq(safe_join([@first_message, @second_message], '<br/>'.html_safe)) }
    end


    describe 'can add a message the default way, then add another with flash_message' do

      before(:each) do
        @f2_type = :florb
        flash[@f2_type] = nil
        flash[@f2_type] = @first_message
        helper.flash_message @f2_type, @second_message
      end

      it { expect(flash[@f2_type].count).to eq 2 }
      it { expect(flash[@f2_type].first).to eq @first_message }
      it { expect(flash[@f2_type].last).to eq @second_message }
      it { expect(flash[@f2_type]).to eq [@first_message, @second_message] }
      it { expect(helper.render_flash_message(flash[@f2_type])).to eq(safe_join([@first_message, @second_message], '<br/>'.html_safe)) }
    end

  end

  describe '#assocation_empty?' do
    it 'true if nil' do
      expect(helper.assocation_empty?(nil)).to be_truthy
    end
  end

  it '#i18n_time_ago_in_words(past_time)' do
    t = Time.now - 1.day
    expect(helper.i18n_time_ago_in_words(t)).to eq("#{I18n.t('time_ago', amount_of_time: time_ago_in_words(t))}")
  end

end
