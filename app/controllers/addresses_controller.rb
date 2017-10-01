class AddressesController < ApplicationController

  before_action :get_address, except: [:new, :create]
  before_action :get_company
  before_action :authorize_address, except: [:new, :create]

  def new
    @address = Address.new
    @address.addressable = @company

    authorize @address
  end

  def create
    @address = Address.new(address_params)
    @address.addressable = @company

    authorize @address

    if @company.addresses.count == 0
      @address.mail = true
      notice = t('.success_sole_address')
    else
      notice = t('.success')
    end

    if @address.save
      redirect_to @company, notice: notice
    else
      flash.now[:alert] = t('.error')
      render :new
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to @company, notice: t('.success')
    else
      flash.now[:alert] = t('.error')
      render :edit
    end
  end

  def destroy
    if @address.destroy
      redirect_to @company, notice: t('addresses.destroy.success')
    else
      translated_errors = helpers.translate_and_join(@address.errors.full_messages)
      helpers.flash_message(:alert, "#{t('addresses.destroy.error')}: #{translated_errors}")
      redirect_to @company
    end
  end

  def set_address_type
    if params[:type] == 'mail'

      @address.mail = true

      # Find prior "mail" address(es) and unset
      prior_addr = (@company.addresses - [@address]).select { |addr| addr.mail }

      prior_addr.each do |addr|
        addr.mail = false
        addr.save
      end

      @address.save

      head :ok
    end
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

  def authorize_address
    authorize @address
  end

end
