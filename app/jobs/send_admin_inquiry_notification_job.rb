class SendAdminInquiryNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(admin_user_id, inquiry_id)
    admin_user = AdminUser.find_by(id: admin_user_id)
    inquiry = ContactInquiry.find_by(id: inquiry_id)

    # Return if admin user or inquiry not found
    return unless admin_user && inquiry

    # Send notification email to admin
    AdminMailer.new_inquiry_notification(admin_user, inquiry).deliver_now
  end
end
