class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :street, :postal_code, :city, :phone, :email_confirmation, :business_number)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :street, :postal_code, :city, :phone, :email_confirmation, :business_number, :current_password)
  end
end
