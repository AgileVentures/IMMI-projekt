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

      before(:each) do
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



  #
  # Separate the Label and Value with the separator string (default = ': ')
  #
  #  Ex:  field_or_default('Name', 'Bob Ross')
  #     will produce:  "<p><span class='field-label'>Name: </span><span class='field-value'>Bob Ross</span></p>"
  #
  # Ex: field_or_default('Name', 'Bob Ross', tag: :h2, separator: ' = ')
  #     will produce:  "<h2><span class='field-label'>Name = </span><span class='field-value'>Bob Ross</span></h2>"
  #
  # Ex: field_or_default('Name', 'Bob Ross', tag_options: {id: 'bob-ross'}, value_class: 'special-value')
  #     will produce:  "<p id='bob-ross'><span class='field-label'>Name: </span><span class='special-value'>Bob Ross</span></p>"

  describe '#field_or_default' do

    it 'nil value returns an empty string' do
      expect(helper.field_or_default('some label', nil)).to eq ''
    end

    it 'empty value returns an empty string by default' do
      expect(helper.field_or_default('some label', '')).to eq ''
    end


    it "can set the default string to a complicated content_tag " do
    #  expect(helper.field_or_default('some label', [], default: (content_tag(:div, class: ["strong", "highlight"]) { 'some default' }) )).to eq('some default')
    end


    it 'non-empty value with defaults == <p><span class="field-label">labelseparator</span><span class="field-value">value</span></p>' do
      expect(helper.field_or_default('label', 'value')).to eq('<p><span class="field-label">label: </span><span class="field-value">value</span></p>')
    end


    it 'can set a custom separator' do
      expect(helper.field_or_default('label', 'value', separator: '???')).to eq('<p><span class="field-label">label???</span><span class="field-value">value</span></p>')
    end


    it 'can set the class of the surrounding tag' do
      expect(helper.field_or_default('label', 'value', tag: :h2)).to eq('<h2><span class="field-label">label: </span><span class="field-value">value</span></h2>')
    end


    it 'can set html options for the surrounding tag' do
      expect(helper.field_or_default('label', 'value', tag_options: {class: "blorf", id: "blorfid"})).to eq('<p class="blorf" id="blorfid"><span class="field-label">label: </span><span class="field-value">value</span></p>')
    end


    it "can set class for the label + separator = 'special-label-class'" do
      expect(helper.field_or_default('label', 'value', label_class: 'special-label-class')).to eq('<p><span class="special-label-class">label: </span><span class="field-value">value</span></p>')
    end


    it "default class for the value = 'special-value-class'" do
      expect(helper.field_or_default('label', 'value', value_class: 'special-value-class')).to eq('<p><span class="field-label">label: </span><span class="special-value-class">value</span></p>')
    end

  end


  describe '#unique_css_id' do

    # t1 = Time.now.utc
    # t1_in_seconds = t1.to_i
    # Time.at(t1_in_seconds).utc.inspect == t1.inspect  # not exact so must use inspect, but close enough in seconds

    it 'company id=23' do
      co = create(:company, id: 23)
      expect(helper.unique_css_id(co)).to eq "company-23"
    end

    it 'unsaved company ' do
      co = build(:company)
      expect(helper.unique_css_id(co)).to match(/^company-no-id--/)
    end

    it 'business_category  4' do
      co = create(:business_category, id: 4)
      expect(helper.unique_css_id(co)).to eq "businesscategory-4"
    end

  end


  describe '#item_view_class ' do

    it 'show company 23' do
      co = create(:company, id: 23)
      expect(helper.item_view_class(co, 'show')).to eq "show company company-23"
    end

    it 'edit company 4' do
      co = create(:company, id: 4)
      expect(helper.item_view_class(co, 'edit')).to eq "edit company company-4"
    end

    it 'new business_category x' do
      co = build(:business_category)
      expect(helper.item_view_class(co, 'new')).to match(/^new businesscategory businesscategory-no-id--/)
    end

  end


end
