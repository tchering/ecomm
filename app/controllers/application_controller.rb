class ApplicationController < ActionController::Base
  include CurrentCart
  include CurrencyConversion

  before_action :set_cart
  before_action :set_current_user
  helper_method :current_cart

  def current_cart
    @cart
  end

  private

  def set_current_user
    Current.user = current_user
  end
end
