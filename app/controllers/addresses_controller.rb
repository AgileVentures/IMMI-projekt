class AddressesController < ApplicationController

  before_action :get_address, except: [:new, :create]
  before_action :get_company

  def new
    @address = Address.new
  end

  def create
  end

  def edit
  end

  def update
    redirect_to company_path(@company)
  end

  def destroy
    redirect_to company_path(@company)
  end

  def set_address_type
  end

  private

  def get_company
    @company = Company.find(params[:company_id])
  end

  def get_address
    @address = Address.find(params[:id])
  end

end
