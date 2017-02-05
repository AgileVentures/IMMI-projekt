class AdminController < ApplicationController
  before_action :authorize_admin


  def index
    @membership_applications = MembershipApplication.all
  end


  # export membership_appplications
  def export_ansokan_csv

    begin
      @membership_applications = MembershipApplication.all

      export_name = "shf-ankosan-#{Time.now.strftime('%Y-%m-%d--%H-%M-%S')}.csv"

      send_data(export_str(@membership_applications), filename: export_name, type: "text/plain" )

      helpers.flash_message(:notice, t('.success'))

    rescue  => e

      helpers.flash_message(:alert, "#{t('.error')} [#{e.message}]")
      redirect_to(request.referer.present? ? :back : root_path)

    end

  end


  private

  def authorize_admin
    AdminPolicy.new(current_user).authorized?
  end


  def export_str(membership_apps)
    out_str = ''
    out_str << "'#{t('activerecord.attributes.membership_application.first_name').strip}',"
    out_str << "'#{t('activerecord.attributes.membership_application.last_name').strip}',"
    out_str << "'#{t('activerecord.attributes.membership_application.contact_email').strip}',"
    out_str << "'#{t('activerecord.attributes.membership_application.state').strip}'\n"

    membership_apps.each do |m_app|
      out_str << "#{m_app.first_name},#{m_app.last_name},#{m_app.contact_email},"
      out_str << t("membership_applications.state.#{m_app.state}")
      out_str << "\n"
    end

    out_str
  end

end
