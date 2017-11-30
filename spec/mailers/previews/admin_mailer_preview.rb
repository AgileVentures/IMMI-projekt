# Preview all emails at http://localhost:3000/rails/mailers

class AdminMailerPreview < ActionMailer::Preview

  include PickRandomHelpers

  def member_application_received
    admin = User.find_by(admin: true)
    AdminMailer.member_application_received(random_member_app, admin)
  end



end
