class NewsletterRecipient < ApplicationRecord
  belongs_to :newsletter
  belongs_to :newsletter_subscription

  validates :newsletter_subscription_id, uniqueness: { scope: :newsletter_id }

  enum status: {
    queued: "queued",
    sent: "sent",
    failed: "failed",
  }

  scope :sent, -> { where(status: :sent) }
  scope :failed, -> { where(status: :failed) }
  scope :queued, -> { where(status: :queued) }

  def mark_as_sent!
    update!(status: :sent, sent_at: Time.current)
  end

  def mark_as_failed!(error_message)
    update!(status: :failed, error_message: error_message)
  end
end
