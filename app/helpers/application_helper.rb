module ApplicationHelper
  def format_price(price)
    converted_price = convert_price(price)

    case current_currency
    when "EUR"
      number_to_currency(converted_price, unit: "€", format: "%u%n")
    when "USD"
      number_to_currency(converted_price, unit: "$", format: "%u%n")
    else
      number_to_currency(converted_price)
    end
  end
end
