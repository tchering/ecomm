module Admin::OrdersHelper
  def status_button_color(status)
    case status
    when "pending"
      "bg-yellow-500"
    when "processing"
      "bg-blue-500"
    when "shipped"
      "bg-purple-500"
    when "delivered"
      "bg-green-500"
    when "cancelled"
      "bg-red-500"
    else
      "bg-gray-500"
    end
  end
end
