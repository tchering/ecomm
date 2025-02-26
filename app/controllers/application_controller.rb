class ApplicationController < ActionController::Base
  include CurrentCart
  include CurrencyConversion

  before_action :set_cart
  before_action :set_current_user
  helper_method :current_cart

  def current_cart
    @cart
  end

  def turbo_visit(url)
    response.headers["Turbo-Visit"] = url
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || stores_path
  end

  def after_sign_out_path_for(resource_or_scope)
    stores_path
  end

  private

  def set_current_user
    Current.user = current_user
  end
end
