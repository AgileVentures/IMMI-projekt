require 'rails_helper'

RSpec.describe 'companies/index' do

  include Devise::Test::ControllerHelpers

  let(:member)  { FactoryGirl.create(:member_with_membership_app) }

  let(:admin)   { FactoryGirl.create(:user, admin: true) }

  let(:cmpy_id) { member.membership_applications[0].company.id }

  let(:app_id)  { member.membership_applications[0].id }

  let(:shf_site) { Regexp.escape('http://sverigeshundforetagare.se/') }

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
        .to match %r{<a href=\"#{shf_site}\">#{text}}
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

  describe 'admin' do

    before(:each) do
      sign_in admin

      render 'application/navigation'
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

    it 'renders link to main site' do
      text = t('menus.nav.shf_main_site')
      expect(rendered)
        .to match %r{<a href=\"#{shf_site}\">#{text}}
    end

    it 'renders link to manage applications' do
      text = t('menus.nav.admin.manage_applications')
      expect(rendered).to match %r{<a href=\"\/ansokan\">#{text}}
    end

    context 'business categories' do

      it 'renders default menu link == list categories' do
        text = t('menus.nav.admin.categories.submenu_title')
        expect(rendered).to match %r{<a href=\"\/kategori\">#{text}}
      end

      it 'renders list-categories link' do
        text = t('menus.nav.admin.categories.list_categories')
        expect(rendered).to match %r{<a href=\"\/kategori\">#{text}}
      end

      it 'renders new-category link' do
        text = t('menus.nav.admin.categories.new_category')
        expect(rendered).to match %r{<a href=\"\/kategori\/ny\">#{text}}
      end
    end

    context 'companies' do

      it 'renders default menu link == list companies' do
        text = t('menus.nav.admin.companies.submenu_title')
        expect(rendered).to match %r{<a href=\"\/hundforetag\">#{text}}
      end

      it 'renders list-companies link' do
        text = t('menus.nav.admin.companies.list_companies')
        expect(rendered).to match %r{<a href=\"\/hundforetag\">#{text}}
      end

      it 'renders new-company link' do
        text = t('menus.nav.admin.companies.new_company')
        expect(rendered).to match %r{<a href=\"\/hundforetag\/ny\">#{text}}
      end
    end

    it 'renders link to users index view' do
      text = t('menus.nav.admin.users.list_users')
      expect(rendered).to match %r{<a href=\"\/anvandare\">#{text}}
    end

    context 'waiting-for-info-reasons menu' do

      it 'renders default menu link == all-reasons list' do
        text = t('menus.nav.admin.member_app_waiting_reasons.submenu_title')
        expect(rendered)
          .to match %r{<a href=\"\/admin\/member_app_waiting_reasons">#{text}}
      end

      it 'renders all-reasons link' do
        text = t('menus.nav.admin.member_app_waiting_reasons.list_member_app_waiting_reasons')
        expect(rendered)
          .to match %r{<a href=\"\/admin\/member_app_waiting_reasons">#{text}}
      end

      it 'renders new-reason link' do
        text = t('menus.nav.admin.member_app_waiting_reasons.new_member_app_waiting_reasons')
        expect(rendered)
          .to match %r{<a href=\"\/admin\/member_app_waiting_reasons\/new">#{text}}
      end
    end
  end

  describe 'visitor' do

    before(:each) { render 'application/navigation' }

    it 'renders link to main site' do
      text = t('menus.nav.home')
      expect(rendered)
        .to match %r{<a href=\"#{shf_site}\">#{text}}
    end

    it 'renders brochure link' do
      text = t('menus.nav.visitor.brochure')
      expect(rendered)
        .to match %r{<a href=\"#{shf_site}broschyr\/\">#{text}}
    end

    context 'for-dog-owners menu' do

      it 'renders menu link == link to SHF site' do
        text = t('menus.nav.visitor.dog_owners.submenu_title')
        expect(rendered).to match %r{<a href=\"#{shf_site}agare\/\">#{text}}
      end

      it 'renders about-us link' do
        text = Regexp.escape(t('menus.nav.visitor.dog_owners.about_us'))
        expect(rendered).to match %r{<a\shref=\"#{shf_site}agare\/
                                     om-sveriges-hundforetagare\/\">#{text}}x
      end

      it 'renders H-label link' do
        text = Regexp.escape(t('menus.nav.visitor.dog_owners.h_label'))
        expect(rendered).to match %r{<a\shref=\"#{shf_site}agare\/
                                     h-markt-av-sveriges-hundforetagare\/\">#{text}}x
      end

      it 'renders knowledge-bank link' do
        text = Regexp.escape(t('menus.nav.visitor.dog_owners.knowledge_bank'))
        expect(rendered).to match %r{<a\shref=\"#{shf_site}category\/
                                     kunskapsbank-hundagare\/\">#{text}}x
      end

      it 'renders are-you-unsatisfied? link' do
        text = Regexp.escape(t('menus.nav.visitor.dog_owners.are_you_unsatisfied'))
        expect(rendered).to match %r{<a\shref=\"#{shf_site}agare\/
                                     ar-du-inte-nojd\/\">#{text}}x
      end

      it 'renders become-a-supporter link' do
        text = t('menus.nav.visitor.dog_owners.become_supporter')
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}agare\/bli-stodmedlem\/\">#{text}}
      end

      it 'renders being-dog-owners link' do
        text = t('menus.nav.visitor.dog_owners.being_dog_owners')
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}agare\/att-vara-hundagare\/\">#{text}}
      end
    end

    context 'dog-company-owners menu' do

      it 'renders menu link == link to SHF site' do
        text = t('menus.nav.visitor.entrepreneurs.submenu_title')
        expect(rendered).to match %r{<a href=\"#{shf_site}foretag\/\">#{text}}
      end

      it 'renders about-us link' do
        text = Regexp.escape(t('menus.nav.visitor.entrepreneurs.about_us'))
        expect(rendered).to match %r{<a\shref=\"#{shf_site}foretag\/
                                     om-sveriges-hundforetagare\/\">#{text}}x
      end

      it 'renders become-a-member link' do
        text = t('menus.nav.visitor.entrepreneurs.sign_up')
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}foretag\/bli-medlem\/\">#{text}}
      end

      it 'renders become-H-labeled link' do
        text = t('menus.nav.visitor.entrepreneurs.be_h_labeled')
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}foretag\/bli-h-markt\/\">#{text}}
      end

      it 'renders member-criteria link' do
        text = t('menus.nav.visitor.entrepreneurs.member_criteria')
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}medlemskriterier\/\">#{text}}
      end

      it 'renders member-benefits link' do
        text = Regexp.escape(t('menus.nav.visitor.entrepreneurs.member_benefits'))
        expect(rendered).to match %r{<a\shref=\"#{shf_site}foretag\/
                                     detta-far-du-som-medlem\/\">#{text}}x
      end

      it 'renders member-standards link' do
        text = t('menus.nav.visitor.entrepreneurs.quality_standards')
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}foretag\/kvalitetskontroll\/\">#{text}}
      end

      it 'renders knowledge-bank link' do
        text = Regexp.escape(t('menus.nav.visitor.entrepreneurs.knowledge_bank'))
        expect(rendered).to match %r{<a\shref=\"#{shf_site}category\/
                                     kunskapsbank-foretagare\/\">#{text}}x
      end
    end

    context 'knowledge-bank menu' do

      it 'renders menu link to empty anchor' do
        text = t('menus.nav.visitor.knowledge_bank.submenu_title')
        expect(rendered).to match %r{<a href=\"\#\">#{text}}
      end

      it 'renders Bloggar link' do
        text = 'Bloggar'
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}category\/bloggar\/\">#{text}}
      end

      it 'renders Böcker link' do
        text = 'Böcker'
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}category\/bocker\/\">#{text}}
      end

      it 'renders Forskning link' do
        text = 'Forskning'
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}category\/forskning\/\">#{text}}
      end

      it 'renders Pod link' do
        text = 'Pod'
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}category\/pod\/\">#{text}}
      end

      it 'renders Populärvetenskap link' do
        text = 'Populärvetenskap'
        expect(rendered)
          .to match %r{<a href=\"#{shf_site}category\/popularvetenskap\/\">#{text}}
      end

      it 'renders Video link' do
        text = 'Video'
        expect(rendered).to match %r{<a href=\"#{shf_site}category\/video\/\">#{text}}
      end
    end

    it 'renders contact link' do
      text = t('menus.nav.visitor.contact')
      expect(rendered).to match %r{<a href=\"#{shf_site}kontakt\/\">#{text}}
    end

    it 'renders find-dog-company link' do
      text = t('menus.nav.visitor.find_dog_businesses')
      expect(rendered).to match %r{<a href=\"\/\">#{text}}
    end
  end
end
