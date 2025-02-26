class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    # Check for redirect notice from session storage
    flash.now[:notice] = "Please log in to add items to your cart" if params[:cart_redirect].present?
    super
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)

    # Use a full page redirect rather than Turbo
    if request.format == :turbo_stream
      redirect_to after_sign_in_path_for(resource), status: :see_other
    else
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out

    # Always use a full page redirect for sign out
    redirect_to after_sign_out_path_for(resource_name), status: :see_other
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  # The path used after signing in
  def after_sign_in_path_for(resource)
    root_path
  end
end
