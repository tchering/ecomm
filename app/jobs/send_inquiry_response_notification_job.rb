class SendInquiryResponseNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(inquiry_id, response_message)
    inquiry = ContactInquiry.find_by(id: inquiry_id)
    return unless inquiry

    ContactMailer.inquiry_response_notification(inquiry, response_message).deliver_now
  end
end
