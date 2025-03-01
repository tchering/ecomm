# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  def new_order_notification
    admin_user = AdminUser.first || AdminUser.create!(
      email: "admin@example.com",
      password: "password",
      password_confirmation: "password",
    )

    order = Order.last || Order.create!(
      name: "Test Customer",
      email: "customer@example.com",
      shipping_address: "123 Test St",
      shipping_city: "Test City",
      shipping_state: "Test State",
      shipping_postal_code: "12345",
      total: 99.99,
      status: "pending",
    )

    AdminMailer.new_order_notification(admin_user, order)
  end

  def new_inquiry_notification
    admin_user = AdminUser.first || AdminUser.create!(
      email: "admin@example.com",
      password: "password",
      password_confirmation: "password",
    )

    inquiry = ContactInquiry.last || ContactInquiry.create!(
      name: "Test Customer",
      email: "customer@example.com",
      subject: "Test Inquiry",
      message: "This is a test inquiry message.",
      status: "new",
    )

    AdminMailer.new_inquiry_notification(admin_user, inquiry)
  end
end
