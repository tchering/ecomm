class ApplicationController < ActionController::Base
  include CurrentCart
  include CurrencyConversion
  
  before_action :set_cart
  helper_method :current_cart

  def current_cart
    @cart
  end
end
