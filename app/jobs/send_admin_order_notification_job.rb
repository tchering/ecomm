class SendAdminOrderNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(admin_user_id, order_id)
    admin_user = AdminUser.find_by(id: admin_user_id)
    order = Order.find_by(id: order_id)

    # Return if admin user or order not found
    return unless admin_user && order

    # Send notification email to admin
    AdminMailer.new_order_notification(admin_user, order).deliver_now
  end
end
