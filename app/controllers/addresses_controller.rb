class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [:edit, :update, :destroy, :set_default]

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)

    if @address.save
      redirect_to profile_path, notice: "Address was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to profile_path, notice: "Address was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to profile_path, notice: "Address was successfully removed."
  end

  def set_default
    @address.update(is_default: true)
    redirect_to profile_path, notice: "Default address updated."
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(
      :street_address,
      :apartment,
      :city,
      :state,
      :postal_code,
      :country,
      :is_default
    )
  end
end
