class SendOrderStatusEmailJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    # Find the order
    order = Order.find_by(id: order_id)

    # Return if order not found
    return unless order

    # Send the appropriate email based on order status
    case order.status
    when "pending"
      OrderMailer.order_confirmation(order).deliver_now
    when "processing"
      OrderMailer.order_processing(order).deliver_now
    when "shipped"
      OrderMailer.order_shipped(order).deliver_now
    when "delivered"
      OrderMailer.order_delivered(order).deliver_now
    when "cancelled"
      OrderMailer.order_cancelled(order).deliver_now
    end
  end
end
