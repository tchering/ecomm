class SendNewsletterJob < ApplicationJob
  queue_as :mailers

  def perform(newsletter_id)
    # Find the newsletter
    newsletter = Newsletter.find_by(id: newsletter_id)

    # Return if newsletter not found
    return unless newsletter

    # Mark newsletter as sending
    newsletter.mark_as_sending!

    begin
      # Get all active subscribers
      subscribers = NewsletterSubscription.active

      # Send newsletter to each subscriber
      subscribers.find_each do |subscriber|
        NewsletterMailer.newsletter_email(newsletter, subscriber).deliver_later
      end

      # Mark newsletter as sent
      newsletter.mark_as_sent!
    rescue => e
      # Log error and mark newsletter as failed
      Rails.logger.error("Failed to send newsletter: #{e.message}")
      newsletter.mark_as_failed!
      raise e
    end
  end
end
