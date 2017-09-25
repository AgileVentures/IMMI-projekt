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

    if @address.save
      redirect_to @company, notice: t('.success')
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
      @address.mail = params[:mail] ? true : false

      if @address.mail  # This address selected to be "mail" address

        # Find prior "mail" address and unset
        (@company.addresses - [@address]).each do |addr|

          if addr.mail
            addr.mail = false
            addr.save

            @address.save

            # AJAX callback to unset addr's "mail" checkbox in view
            render json: { type: 'mail', address_id: addr.id }
            return
          end
        end
      end
    end
    render nothing: true
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
