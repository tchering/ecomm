module CurrencyConversion
  extend ActiveSupport::Concern

  included do
    helper_method :current_currency, :convert_price
    before_action :set_currency
  end

  private

  def set_currency
    if params[:currency].present? && ['EUR', 'USD'].include?(params[:currency])
      session[:currency] = params[:currency]
      # Redirect to the same page without the currency parameter to keep URLs clean
      redirect_to(request.path) unless request.format.turbo_stream?
    end
    session[:currency] ||= 'EUR'
  end

  def current_currency
    session[:currency]
  end

  def convert_price(price)
    return price if price.nil?
    return price if current_currency == 'EUR'

    case current_currency
    when 'USD'
      (price * 1.08).round(2)  # 1 EUR = 1.08 USD
    else
      price
    end
  end
end
