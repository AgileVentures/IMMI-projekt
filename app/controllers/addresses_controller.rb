class AddressesController < ApplicationController

  before_action :get_address, except: [:new, :create]
  before_action :get_company
  before_action :authorize_company, only: [:update, :show, :edit, :destroy]

  def new
    # authorize Address

    @address = Address.new
  end

  def create
    # authorize Address

    @address = Address.new(address_params)
    @address.addressable = @company

    if @address.save
      redirect_to @company, notice: t('.success')
    else
      flash.now[:alert] = t('.error')
      render :new
    end
  end

  def edit
    # authorize
  end

  def update
    # authorize

    if @address.update(address_params)
      redirect_to @company, notice: t('.success')
    else
      flash.now[:alert] = t('.error')
      render :edit
    end
  end

  def destroy
    # authorize

    if @address.destroy
      redirect_to @company, notice: t('addresses.destroy.success')
    else
      translated_errors = helpers.translate_and_join(@address.errors.full_messages)
      helpers.flash_message(:alert, "#{t('addresses.destroy.error')}: #{translated_errors}")
      redirect_to @company
    end
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

  def address_params
    params.require(:address).permit(:street_address, :post_code, :city,
                                    :kommun_id, :region_id, :visibility)
  end

  def authorize_company
    authorize @company
  end

end
