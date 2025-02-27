# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview
  def new_inquiry_notification
    inquiry = ContactInquiry.last || create_sample_inquiry
    ContactMailer.new_inquiry_notification(inquiry)
  end

  def inquiry_confirmation
    inquiry = ContactInquiry.last || create_sample_inquiry
    ContactMailer.inquiry_confirmation(inquiry)
  end

  def admin_response
    contact_inquiry = ContactInquiry.first || ContactInquiry.create!(
      name: "John Doe",
      email: "john@example.com",
      subject: "Test Subject",
      message: "Test Message",
    )

    admin = AdminUser.first || AdminUser.create!(
      email: "admin@example.com",
      password: "password",
      password_confirmation: "password",
    )

    response = ContactResponse.create!(
      contact_inquiry: contact_inquiry,
      user: admin,
      message: "Thank you for your inquiry. We'll get back to you soon.",
    )

    ContactMailer.admin_response(response)
  end

  private

  def create_sample_inquiry
    ContactInquiry.create!(
      name: "Sample User",
      email: "user@example.com",
      subject: "Sample Inquiry",
      message: "This is a sample inquiry message for email previews. I have a question about your products.",
      status: "new",
    )
  end

  def create_sample_response
    inquiry = ContactInquiry.last || create_sample_inquiry
    admin = Admin.first || Admin.create!(
      email: "admin@example.com",
      password: "password",
    )

    ContactResponse.create!(
      contact_inquiry: inquiry,
      user: admin,
      message: "Thank you for your inquiry. This is a sample response from our team.",
      sent_at: Time.current,
    )
  end
end
