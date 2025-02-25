class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :deactivate]
  layout "admin"

  def index
    @users = User.all
    @users = @users.where(is_admin: true) if params[:role] == "admin"
    @users = @users.where(is_admin: false) if params[:role] == "customer"
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.soft_delete
    redirect_to admin_users_path, notice: "User was successfully deactivated."
  end

  def deactivate
    @user.soft_delete
    redirect_to admin_users_path, notice: "User was successfully deactivated."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :phone_number, :is_admin)
  end
end
