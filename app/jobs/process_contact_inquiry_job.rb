class ProcessContactInquiryJob < ApplicationJob
  queue_as :mailers

  def perform(contact_inquiry_id)
    # Find the contact inquiry
    inquiry = ContactInquiry.find_by(id: contact_inquiry_id)

    # Return if inquiry not found
    return unless inquiry

    # Send notification to admin
    ContactMailer.new_inquiry_notification(inquiry).deliver_now

    # Send confirmation to user
    ContactMailer.inquiry_confirmation(inquiry).deliver_now
  end
end
