require 'rails_helper'
include ApplicationHelper

RSpec.describe UserChecklistsHelper, type: :helper do

  describe 'fa_is_complete_checkbox' do

    describe 'user_checklist is not completed' do
      let(:not_completed_checklist) { create(:user_checklist) }
      let(:resulting_html) { helper.fa_is_complete_checkbox(not_completed_checklist) }

      it 'title says the <name of the checklist> is not complete' do
        expect(resulting_html).to match(/<i title="#{not_completed_checklist.name} #{I18n.t('activerecord.attributes.user_checklist.not_completed')}"(.*)><\/i>/)
      end

      it 'icon is fa-square (style = far)' do
        expect(resulting_html).to match(/<i(.*)class="far fa-square"(.*)><\/i>/)
      end
    end

    describe 'user_checklist is completed' do

      let(:completed_checklist) { create(:user_checklist, :completed) }
      let(:resulting_html) { helper.fa_is_complete_checkbox(completed_checklist) }

      it 'title says the <name of the checklist> is completed' do
        expect(resulting_html).to match(/<i(.*)title="#{completed_checklist.name} #{I18n.t('activerecord.attributes.user_checklist.completed')}"(.*)><\/i>/)
      end

      it 'icon is fa-check-square (style = far)' do
        expect(resulting_html).to match(/<i(.*)class="far fa-check-square"(.*)><\/i>/)
      end
    end

    it 'html options given are merged in' do
      expect(helper.fa_is_complete_checkbox(create(:user_checklist), { blorf: 'flurb' })).to match(/<i(.*)blorf="flurb"(.*)><\/i>/)
    end
  end


  it 'is_completed_checkbox(user_checklist)' do
    expect(is_completed_checkbox(create(:user_checklist))).to match(/<input type="checkbox" name="completed-checkbox" id="completed-checkbox" value="checked" class="checkbox.completed-checkbox" data-remote="true" data-method="post" data-url="\/anvandare\/lista\/all_changed_by_completion_toggle\/(\d+)s*/)
  end


  describe 'ul_id' do
    it 'creates a string starting with ul-id- and ending with the user_checklist id' do
      new_checklist = create(:user_checklist)
      expect(helper.ul_id.call(new_checklist)).to eq "ul-id-#{new_checklist.id}"
    end
  end


  describe 'li_id' do
    it 'creates a string starting with li-id- and ending with the user_checklist id' do
      new_checklist = create(:user_checklist)
      expect(helper.li_id.call(new_checklist)).to eq "li-id-#{new_checklist.id}"
    end
  end

end
