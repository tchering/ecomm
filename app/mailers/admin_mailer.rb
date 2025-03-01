class AdminMailer < ApplicationMailer
  # Send notification to admin about new order
  def new_order_notification(admin_user, order)
    @admin_user = admin_user
    @order = order
    @url = admin_order_url(@order)

    mail(
      to: admin_user.email,
      subject: "New Order ##{order.id} Received",
    )
  end

  # Send notification to admin about new inquiry
  def new_inquiry_notification(admin_user, inquiry)
    @admin_user = admin_user
    @inquiry = inquiry
    @url = admin_contact_inquiry_path(@inquiry)

    mail(
      to: admin_user.email,
      subject: "New Contact Inquiry: #{inquiry.subject}",
    )
  end
end
