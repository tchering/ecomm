class OrderMailer < ApplicationMailer
  # Order confirmation email
  def order_confirmation(order)
    @order = order
    @user = order.user
    attachments["invoice.pdf"] = OrderInvoicePdf.new(order).render
    mail(
      to: order.email,
      subject: "Order Confirmation - ##{order.id}",
    )
  end

  # Order processing email
  def order_processing(order)
    @order = order
    @user = order.user
    mail(
      to: order.email,
      subject: "Your Order ##{order.id} is Being Processed",
    )
  end

  # Order shipped email
  def order_shipped(order)
    @order = order
    @user = order.user
    mail(
      to: order.email,
      subject: "Your Order ##{order.id} Has Been Shipped",
    )
  end

  # Order delivered email
  def order_delivered(order)
    @order = order
    @user = order.user
    mail(
      to: order.email,
      subject: "Your Order ##{order.id} Has Been Delivered",
    )
  end

  # Order cancelled email
  def order_cancelled(order)
    @order = order
    @user = order.user
    mail(
      to: order.email,
      subject: "Your Order ##{order.id} Has Been Cancelled",
    )
  end
end
