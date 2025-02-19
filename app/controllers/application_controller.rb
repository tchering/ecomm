class ApplicationController < ActionController::Base
  include CurrentCart
  before_action :set_cart
  helper_method :current_cart

  def current_cart
    @cart
  end
end
