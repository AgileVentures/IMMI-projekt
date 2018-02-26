require 'rails_helper'

RSpec.describe 'companies/index' do

  let(:member)  { FactoryGirl.create(:member_with_membership_app) }

  let(:admin)   { FactoryGirl.create(:user, admin: true) }

  let(:user)    { FactoryGirl.create(:user_with_membership_app) }

  let(:cmpy_id) { member.shf_application.company.id }
  let(:cmpy_id) { member.shf_application.company.id }

  let(:app_id)  { member.shf_application.id }

  let(:user_app_id) { user.shf_application.id }

  let(:shf_site) { Regexp.escape('http://sverigeshundforetagare.se/') }

  # https://stackoverflow.com/questions/41762057/
  # rails-view-specs-referenced-partials-of-inherited-controllers-arent-found/
  # 41762292#41762292
  before(:each) { view.lookup_context.prefixes << 'application' }

  describe 'member' do

    before(:each) do
      allow(view).to receive(:current_user) { member }
      allow(view).to receive(:user_signed_in?) { true }

      #https://github.com/elabs/pundit/issues/339
      #undefined method `policy' while testing with RSpec views specs
      without_partial_double_verification do
        allow(view).to receive(:policy).and_return(double('ShfApplicationPolicy.new', update?: false))
      end

      assign(:all_visible_companies, [])
      assign(:search_params, Company.ransack(nil))
      assign(:companies, Company.ransack(nil).result.page(params[:page]).per_page(10))

      render 'application/navigation'
    end

    it 'renders link to main site' do
      text = t('menus.nav.shf_main_site')
      expect(rendered).to match %r{<a href=\"#{shf_site}\">#{text}}
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
        expect(rendered).to match %r{<a href=\"\/medlemssidor\">#{text}}
      end

      it 'renders link to view SHF Board meeting minutes' do
        text = t('menus.nav.members.shf_meeting_minutes')
        expect(rendered).to match %r{<a href=\"\/dokument">#{text}}
      end
    end

    context 'manage my company menu' do

      it 'renders default menu link == view-my-company' do
        text = t('menus.nav.members.manage_company.submenu_title')
        expect(rendered).to match %r{<a href=\"\/hundforetag\/#{cmpy_id}\">#{text}}
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

    context 'logged-in menu' do
      it 'renders logged-in greeting' do
        expect(rendered).to match %r{#{t('hello', name: member.first_name)}}
      end

      it 'renders log-off link' do
        expect(rendered).to match %r{#{t('devise.sessions.destroy.log_out')}}
      end

      it 'renders edit-profile link' do
        expect(rendered).to match %r{#{t('devise.registrations.edit.title')}}
      end
    end
  end

  describe 'user with application' do

    before(:each) do
      allow(view).to receive(:current_user) { user }
      allow(view).to receive(:user_signed_in?) { true }

      #https://github.com/elabs/pundit/issues/339
      #undefined method `policy' while testing with RSpec views specs
      without_partial_double_verification do
        allow(view).to receive(:policy).and_return(double('ShfApplicationPolicy.new', update?: true))
      end

      assign(:all_visible_companies, [])
      assign(:search_params, Company.ransack(nil))
      assign(:companies, Company.ransack(nil).result.page(params[:page]).per_page(10))

      render 'application/navigation'
    end

    it 'renders link to main site' do
      text = t('menus.nav.shf_main_site')
      expect(rendered).to match %r{<a href=\"#{shf_site}\">#{text}}
    end

    it 'renders link to companies index view' do
      text = t('menus.nav.members.shf_companies')
      expect(rendered).to match %r{<a href=\"\/\">#{text}}
    end

    it 'renders link to edit my application' do
      text = t('menus.nav.users.my_application')
      expect(rendered).to match %r{<a href=\"\/ansokan\/#{user_app_id}\/redigera\">#{text}}
    end

    context 'logged-in menu' do
      it 'renders logged-in greeting' do
        expect(rendered).to match %r{#{t('hello', name: user.first_name)}}
      end

      it 'renders log-off link' do
        text = t('devise.sessions.destroy.log_out')
        expect(rendered).to match %r{<a.*href=\"\/users\/sign_out\">#{text}}
      end

      it 'renders edit-profile link' do
        text = t('devise.registrations.edit.title')
        expect(rendered).to match %r{<a.*href=\"\/users\/edit\">#{text}}
      end
    end
  end


  describe 'admin' do

    before(:each) do
      allow(view).to receive(:current_user) { admin }
      allow(view).to receive(:user_signed_in?) { true }

      render 'application/navigation'
    end

    context 'member pages' do

      it 'renders menu link == member pages index' do
        text = t('menus.nav.members.member_pages')
        expect(rendered).to match %r{<a href=\"\/medlemssidor\">#{text}}
      end

      it 'renders link to view SHF Board meeting minutes' do
        text = t('menus.nav.members.shf_meeting_minutes')
        expect(rendered).to match %r{<a href=\"\/dokument">#{text}}
      end
    end

    it 'renders link to main site' do
      text = t('menus.nav.shf_main_site')
      expect(rendered).to match %r{<a href=\"#{shf_site}\">#{text}}
    end

    context 'membership applications' do

      it 'renders submenu title' do
        text = t('menus.nav.admin.applications.submenu_title')
        expect(rendered).to match %r{#{text}}
      end

      it 'renders manage-applications link' do
        text = t('menus.nav.admin.applications.manage_applications')
        expect(rendered).to match %r{<a href=\"\/ansokan\">#{text}}
      end

      it 'renders waiting-reasons link' do
        text = t('menus.nav.admin.applications.waiting_reasons')
        expect(rendered).to match %r{<a href=\"\/admin\/member_app_waiting_reasons\">#{text}}
      end

    end

    context 'business categories' do

      it 'renders submenu title' do
        text = t('menus.nav.admin.categories.submenu_title')
        expect(rendered).to match %r{#{text}}
      end

      it 'renders manage-categories link' do
        text = t('menus.nav.admin.categories.manage_categories')
        expect(rendered).to match %r{<a href=\"\/kategori\">#{text}}
      end

      it 'renders new-category link' do
        text = t('menus.nav.admin.categories.new_category')
        expect(rendered).to match %r{<a href=\"\/kategori\/ny\">#{text}}
      end
    end

    context 'companies' do

      it 'renders submenu title' do
        text = t('menus.nav.admin.companies.submenu_title')
        expect(rendered).to match %r{#{text}}
      end

      it 'renders manage-companies link' do
        text = t('menus.nav.admin.companies.manage_companies')
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

    context 'logged-in menu' do
      it 'renders logged-in greeting' do
        expect(rendered).to match %r{#{t('hello', name: admin.first_name)}}
      end

      it 'renders log-off link' do
        expect(rendered).to match %r{#{t('devise.sessions.destroy.log_out')}}
      end

      it 'renders edit-profile link' do
        expect(rendered).to match %r{#{t('devise.registrations.edit.title')}}
      end

      it 'renders view-your-account link' do
        expect(rendered).to match %r{#{t('menus.nav.users.your_account')}}
      end

      it 'renders app-configuration link' do
        expect(rendered).to match %r{#{t('menus.nav.admin.app_configuration')}}
      end
    end

  end

  describe 'visitor' do

    before(:each) do
      allow(view).to receive(:current_user) { Visitor.new }

      render 'application/navigation'
    end

    it 'renders link to main site' do
      text = t('menus.nav.home')
      expect(rendered).to match %r{<a href=\"#{shf_site}\">#{text}}
    end

    it 'renders brochure link' do
      text = t('menus.nav.visitor.brochure')
      expect(rendered).to match %r{<a href=\"#{shf_site}broschyr\/\">#{text}}
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
        text = t('menus.nav.visitor.find_dog_businesses')
        expect(rendered).to match %r{<a href=\"\/">#{text}}
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
        expect(rendered).to match %r{<a.*href=\'\#\'>#{text}}
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

    it 'renders log-in link' do
      text = t('devise.sessions.new.log_in')
      expect(rendered).to match %r{<a .* href=\"\/users\/sign_in">#{text}}
    end
  end
end
