class NewsletterSenderJob < ApplicationJob
  queue_as :mailers

  def perform(newsletter_id)
    newsletter = Newsletter.find_by(id: newsletter_id)
    return unless newsletter

    begin
      # Create recipients for all active subscribers
      NewsletterSubscription.active.find_each do |subscription|
        NewsletterRecipient.create!(
          newsletter: newsletter,
          newsletter_subscription: subscription,
          status: :queued,
        )
      end

      # Send to each recipient
      newsletter.newsletter_recipients.queued.find_each do |recipient|
        begin
          NewsletterMailer.campaign(newsletter, recipient.newsletter_subscription).deliver_now
          recipient.mark_as_sent!
        rescue => e
          recipient.mark_as_failed!(e.message)
        end
      end

      # Update newsletter status
      if newsletter.newsletter_recipients.failed.any?
        newsletter.update!(
          status: :failed,
          sent_at: Time.current,
        )
      else
        newsletter.update!(
          status: :sent,
          sent_at: Time.current,
        )
      end
    rescue => e
      newsletter.update!(status: :failed)
      raise e # Re-raise the error for Sidekiq to handle
    end
  end
end
