# Preview all emails at http://localhost:3000/rails/mailers

class UserMailerPreview < ActionMailer::Preview

  include PickRandomHelpers


  def reset_password_instructions
    UserMailer.reset_password_instructions(random_user, "faketoken", {})
  end


end
