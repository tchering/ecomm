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

  def status_color(status)
    case status
    when "pending", :pending
      "bg-yellow-100 text-yellow-800"
    when "processing", :processing
      "bg-blue-100 text-blue-800"
    when "shipped", :shipped
      "bg-indigo-100 text-indigo-800"
    when "delivered", :delivered
      "bg-green-100 text-green-800"
    when "cancelled", :cancelled
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
