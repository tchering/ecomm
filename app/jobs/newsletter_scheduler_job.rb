class NewsletterSchedulerJob < ApplicationJob
  queue_as :default

  def perform(newsletter_id)
    newsletter = Newsletter.find_by(id: newsletter_id)
    return unless newsletter && newsletter.scheduled?

    # Check if it's time to send
    if Time.current >= newsletter.scheduled_for
      newsletter.send_now!
    else
      # Reschedule for later
      self.class.set(wait_until: newsletter.scheduled_for).perform_later(newsletter_id)
    end
  end
end
