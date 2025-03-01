class ContactMailer < ApplicationMailer
  # Send notification to admin about new inquiry
  def new_inquiry_notification(inquiry)
    @inquiry = inquiry

    mail(
      to: admin_email,
      subject: "New Contact Inquiry: #{inquiry.subject}",
    )
  end

  # Send confirmation to user
  def inquiry_confirmation(inquiry)
    @inquiry = inquiry

    mail(
      to: inquiry.email,
      subject: "We've Received Your Inquiry",
    )
  end

  # Send admin response to user
  def admin_response(response)
    @response = response
    @inquiry = response.contact_inquiry

    mail(
      to: @inquiry.email,
      subject: "Response to Your Inquiry: #{@inquiry.subject}",
      reply_to: admin_email,
    )
  end

  def inquiry_response_notification(inquiry, response_message)
    @inquiry = inquiry
    @response_message = response_message
    @greeting = Time.current.hour < 12 ? "Good morning" : (Time.current.hour < 17 ? "Good afternoon" : "Good evening")

    mail(
      to: @inquiry.email,
      subject: "Re: #{@inquiry.subject} - Response from Our Team",
      reply_to: "support@yourdomain.com",
    )
  end
end
