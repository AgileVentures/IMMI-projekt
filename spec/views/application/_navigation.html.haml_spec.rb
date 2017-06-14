require 'rails_helper'

RSpec.describe 'companies/index' do

  include Devise::Test::ControllerHelpers

  let(:member)  { FactoryGirl.create(:member_with_membership_app) }

  let(:cmpy_id) { member.membership_applications[0].company.id }

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
