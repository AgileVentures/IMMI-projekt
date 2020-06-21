require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:user) { create(:user) }  # FIXME  why is this needed here?  It should be defined only in the tests that require it

  describe '#flash_class' do

    it 'adds correct class on notice' do
      expect(helper.flash_class(:notice)).to eq 'success'
    end

    it 'adds correct class on alert' do
      expect(helper.flash_class(:alert)).to eq 'danger'
    end

    it 'adds correct class on warn' do
      expect(helper.flash_class(:warn)).to eq 'warning'
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

  describe '#association_empty?' do
    it 'true if nil' do
      expect(helper.association_empty?(nil)).to be_truthy
    end
  end

  it '#i18n_time_ago_in_words(past_time)' do
    t = Time.zone.now - 1.day
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
      expect(helper.field_or_default('some label', [], default: (content_tag(:div, class: ["strong", "highlight"]) { 'some default' }) )).to eq('<div class="strong highlight">some default</div>')
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


  describe '#field_or_none' do
    #  def field_or_none(label, value, tag: :p, tag_options: {}, separator: ': ', label_class: 'field-label', value_class: 'field-value')

    it 'nil value returns empty string' do
      expect(helper.field_or_none('label', nil)).to eq ''
    end

    it "default tag is <p>, default class is'field-value', default separator is :" do
      expect(helper.field_or_none('label', 'value')).to eq('<p><span class="field-label">label: </span><span class="field-value">value</span></p>')
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

  describe '#paginate_count_options' do

    let(:expected_default) do
      "<option selected=\"selected\" value=\"10\">10</option>\n<option " +
      "value=\"25\">25</option>\n<option value=\"50\">50</option>\n<option " +
      "value=\"All\">All</option>"
    end

    let(:default_options) { paginate_count_options }

    it 'returns default select options for items per-page' do
      expect(default_options).to eq expected_default
    end

    it 'sets selected to 25' do
      expect(paginate_count_options(25)).to match(/.*selected\" value=\"25\".*/)
    end

    it 'sets selected to 50' do
      expect(paginate_count_options(50)).to match(/.*selected\" value=\"50\".*/)
    end

    it 'sets selected to All' do
      expect(paginate_count_options('All')).to match(/.*selected\" value=\"All\".*/)
    end
  end

  describe '#model_errors_helper' do

    let(:good_ma) { FactoryBot.create(:shf_application) }

    let(:user)    { FactoryBot.create(:user) }

    after(:each) do
      I18n.locale = I18n.default_locale
    end

    let(:errors_html_sv)  do
      I18n.locale = :sv
      ma = ShfApplication.new
      ma.valid?
      model_errors_helper(ma)
    end

    let(:errors_html_en)  do
      I18n.locale = :en
      ma = ShfApplication.new
      ma.valid?
      model_errors_helper(ma)
    end

    it 'returns nil if no errors' do
      expect(model_errors_helper(good_ma)).to be_nil
    end

    it 'adds a count of errors' do
      I18n.locale = :sv
      expect(errors_html_sv).to match(/#{t('model_errors', count: 6)}/)
      I18n.locale = :en
      expect(errors_html_en).to match(/#{t('model_errors', count: 6)}/)
    end

    it 'returns all model errors - swedish' do
      expect(errors_html_sv).to match(/Kontakt e-post måste anges/)

      expect(errors_html_sv).to match(/Kontakt e-post har fel format/)
    end

    it 'returns all model errors - english' do
      expect(errors_html_en).to match(/Contact Email cannot be blank/)

      expect(errors_html_en).to match(/Contact Email is invalid/)
    end
  end

  describe '#boolean_radio_buttons_collection' do
    let(:collection_sv)  do
      I18n.locale = :sv
      boolean_radio_buttons_collection
    end

    let(:collection_en)  do
      I18n.locale = :en
      boolean_radio_buttons_collection
    end

    let(:collection_custom)  do
      I18n.locale = :en
      boolean_radio_buttons_collection(true: 'save', false: 'delete')
    end

    after(:each) do
      I18n.locale = I18n.default_locale
    end

    it 'returns yes/no text values - swedish' do
      expect(collection_sv).to eq [ [true, 'Ja'], [false, 'Nej'] ]
    end

    it 'returns yes/no text values - english' do
      expect(collection_en).to eq [ [true, 'Yes'], [false, 'No'] ]
    end

    it 'returns custom text values' do
      expect(collection_custom).to eq [ [true, 'Save'], [false, 'Delete'] ]
    end
  end


  describe 'fas_tooltip' do

    # <span><i data-toggle=\"tooltip\" data-original-title=\"test\" class=\"fas fa-info-circle\"></i></span>
    it 'returns a <span> with an icon' do
      expect(helper.fas_tooltip('test')).to match(/<span><i (.*)<\/i><\/span>/)
    end

    it "sets data-toggle:'tooltip' and puts the given text into data-original-title" do
      expect(helper.fas_tooltip('test')).to match(/data-toggle="tooltip"/)
    end

    it "puts the text into the date-original-title" do
      expect(helper.fas_tooltip('test')).to match(/data-original-title="test"/)
    end

    it "default icon is 'fa-info-circle'" do
      expect(helper.fas_tooltip('test')).to match(/class="(.*)fa-info-circle"/)
    end

    it "default icon group is 'fas'" do
      expect(helper.fas_tooltip('test')).to match(/class="fas(.*)"/)
    end

    it "can set the icon to 'blorf' and it prepends it with 'fa-'" do
      expect(helper.fas_tooltip('test', fa_icon: 'blorf')).to match(/class="(.*)fa-blorf"/)
    end

    it "can set the icon group to 'faz'" do
      expect(helper.fas_tooltip('test', fa_icon_group: 'faz')).to match(/class="faz(.*)"/)
    end
  end



  describe '#full_page_title' do

    it 'is <page title> | <site name>' do
      expect(helper.full_page_title(page_title: 'PageTitle', site_name: 'SiteName')).to eq "PageTitle | SiteName"
    end

    context 'no page title or site name given' do
      it 'gets both from AppConfiguration' do
        expect(helper.full_page_title).to eq "#{AdminOnly::AppConfiguration.config_to_use.site_meta_title} | #{AdminOnly::AppConfiguration.config_to_use.site_name}"
      end
    end

    context 'only page title given' do
      it 'uses the given page title, gets site name from AdminOnly::AppConfiguration.config_to_use' do
        expect(helper.full_page_title(page_title: 'PageTitle')).to eq "PageTitle | #{AdminOnly::AppConfiguration.config_to_use.site_name}"
      end
    end

    context 'only site name given' do
      it 'uses the given site name, gets page title from AdminOnly::AppConfiguration.config_to_use' do
        expect(helper.full_page_title(site_name: 'SiteName')).to eq "#{AdminOnly::AppConfiguration.config_to_use.site_meta_title} | SiteName"
      end
    end

    context 'both page title the site name given' do
      it 'uses the given site name, gets page title from AdminOnly::AppConfiguration.config_to_use' do
        expect(helper.full_page_title(page_title: "PageTitle", site_name: 'SiteName')).to eq "PageTitle | SiteName"
      end
    end

    context 'page_title is blank' do
      it 'uses the page title from AdminOnly::AppConfiguration.config_to_use' do
        expect(helper.full_page_title(page_title: '', site_name: 'SiteName')).to eq "#{AdminOnly::AppConfiguration.config_to_use.site_meta_title} | SiteName"
      end
    end

    context 'site name is blank' do
      it 'uses the site name from AdminOnly::AppConfiguration.config_to_use' do
        expect(helper.full_page_title(page_title: 'PageTitle', site_name: '')).to eq "PageTitle | #{AdminOnly::AppConfiguration.config_to_use.site_name}"
      end
    end
  end


  describe '#presence_required?' do

    # the simplest model that has a presence validation
    let(:biz_cat_model) { create(:business_category) }

    describe 'model has no presence validators' do

      it 'always false' do
        allow(biz_cat_model.class).to receive(:validators).and_return([])
        expect(helper.presence_required?(biz_cat_model, :name)).to be_falsey
      end
    end

    describe 'model has at least 1 presence validator' do

      it 'false if attribute does not have a presence validator' do
        expect(helper.presence_required?(biz_cat_model, :description)).to be_falsey
      end

      it 'true if attribute does have a presence validator' do
        expect(helper.presence_required?(biz_cat_model, :name)).to be_truthy
      end
    end
  end

  describe 'icon_link' do
    it 'returns the HTML for a link to the url with the FontAwesome (fa) icon name given, target = blank (open in a new window)' do
      expect(helper.icon_link('http://example.com', 'facebook-square')).to eq "<a target=\"_blank\" href=\"http://example.com\"><i class=\"fab fa-facebook-square fa-2x\"></i></a>"
    end

    describe 'icon' do
      it 'returns nil if the icon is nil' do
        expect(helper.icon_link('http://example.com', nil)).to be_nil
      end
    end

    describe 'url' do
      it 'returns nil if url is empty or nil' do
        expect(helper.icon_link(nil, 'facebook-square')).to be_nil
      end
    end
  end


  describe '#with_admin_css_class_if_needed' do

    describe 'user is not an admin: always returns the list of CSS classes given' do

      let(:not_admin) { create(:user) }

      it 'no list given' do
        expect(helper.with_admin_css_class_if_needed(not_admin)). to eq([])
      end

      it 'empty list given' do
        expect(helper.with_admin_css_class_if_needed(not_admin, [])). to eq([])
      end

      it 'given a list of CSS classes' do
        given_list_of_classes = ['this-css-class', 'that-css-class']
        expect(helper.with_admin_css_class_if_needed(not_admin, given_list_of_classes)). to eq(given_list_of_classes)
      end
    end

    describe 'user is an admin' do

      let(:admin) { create(:admin) }

      it 'no list given' do
        expect(helper.with_admin_css_class_if_needed(admin)). to match_array([helper.admin_css_class])
      end

      it 'empty list given' do
        expect(helper.with_admin_css_class_if_needed(admin, [])). to match_array([helper.admin_css_class] )
      end

      it 'given a list of CSS classes' do
        given_list_of_classes = ['this-css-class', 'that-css-class']
        expected_list_of_classes = given_list_of_classes + [helper.admin_css_class]
        expect(helper.with_admin_css_class_if_needed(admin, given_list_of_classes)). to match_array(expected_list_of_classes )
      end
    end

  end


  describe '#yes_no_span' do

    describe "text is t('yes') or t('no')" do

      it "t('yes') if boolean is true" do
        expect(helper.yes_no_span(true)).to match(/<span(.*)>#{I18n.t('yes')}<\/span>/)
      end

      it "t('no') if boolean is false" do
        expect(helper.yes_no_span(false)).to match(/<span(.*)>#{I18n.t('no')}<\/span>/)
      end
    end

    it 'calls span_with_yes_no_css_class to set the span css class, also based on the boolean value' do
      boolean_value = false
      expect(helper).to receive(:span_with_yes_no_css_class).with(anything, boolean_value)

      helper.yes_no_span(boolean_value)
    end
  end


  describe '#span_with_yes_no_css_class' do

    it 'text is surrounded with a span tag' do
      expect(helper.span_with_yes_no_css_class('text', true)).to match(/<span(.*)>text<\/span>/)
    end

    it 'css class is set to the yes css class if boolean is true' do
      expect(helper.span_with_yes_no_css_class('text', true)).to match(/<(.*)class=.#{helper.yes_css_class}(.*)>text<\/span>/)
    end

    it 'css class is set to the no css class if boolean is false' do
      expect(helper.span_with_yes_no_css_class('text', false)).to match(/<(.*)class=.#{helper.no_css_class}(.*)>text<\/span>/)
    end
  end

end
