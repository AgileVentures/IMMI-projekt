require 'rails_helper'

RSpec.describe 'companies/index' do

  include Devise::Test::ControllerHelpers

  let(:member)  { FactoryGirl.create(:member_with_membership_app) }

  let(:cmpy_id) { member.membership_applications[0].company.id }

  let(:app_id)  { member.membership_applications[0].id }

  before(:each) { view.lookup_context.prefixes << 'application' }
    # https://stackoverflow.com/questions/41762057/
    # rails-view-specs-referenced-partials-of-inherited-controllers-arent-found/
    # 41762292#41762292

  describe 'member' do

    before(:each) do
      sign_in member

      assign(:all_visible_companies, [])
      assign(:search_params, Company.ransack(nil))
      assign(:companies, Company.ransack(nil).result.page(params[:page]).per_page(10))

      render 'application/navigation'
    end

    it 'renders link to main site' do
      text = t('menus.nav.shf_main_site')
      expect(rendered)
        .to match %r{<a href=\"http:\/\/sverigeshundforetagare.se\/\">#{text}}
    end

    it 'renders link to companies index view' do
      text = t('menus.nav.members.shf_companies')
      expect(rendered).to match %r{<a href=\"\/\">#{text}}
    end

    it 'renders link to my application' do
      text = t('menus.nav.users.my_application')
      expect(rendered).to match %r{<a href=\"\/ansokan\/#{app_id}\">#{text}}
    end

    context 'member pages' do

      it 'renders menu link == member pages index' do
        text = t('menus.nav.members.member_pages')
        expect(rendered).to match %r{<a href=\"\/member-pages\">#{text}}
      end

      it 'renders link to view SHF Board meeting minutes' do
        text = t('menus.nav.members.shf_meeting_minutes')
        expect(rendered).to match %r{<a href=\"\/shf_documents">#{text}}
      end
    end

    context 'manage my company menu' do

      it 'renders default menu link == view-my-company' do
        text = t('menus.nav.members.manage_company.submenu_title')
        expect(rendered)
          .to match %r{<a href=\"\/hundforetag\/#{cmpy_id}\">#{text}}
      end

      it 'renders view-my-company link' do
        text = t('menus.nav.members.manage_company.view_company')
        expect(rendered)
          .to match %r{<a href=\"\/hundforetag\/#{cmpy_id}\">#{text}}
      end

      it 'renders edit-my-company link' do
        text = t('menus.nav.members.manage_company.edit_company')
        expect(rendered)
          .to match %r{<a href=\"\/hundforetag\/#{cmpy_id}\/redigera\">#{text}}
      end
    end
  end
end
