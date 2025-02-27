class Newsletter < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :content, presence: true

  # Enums
  enum status: {
    draft: 0,
    scheduled: 1,
    sending: 2,
    sent: 3,
    failed: 4,
  }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :drafts, -> { where(status: :draft) }
  scope :sent, -> { where(status: :sent) }

  # Methods
  def mark_as_sending!
    update(status: :sending)
  end

  def mark_as_sent!
    update(status: :sent, sent_at: Time.current)
  end

  def mark_as_failed!
    update(status: :failed)
  end

  def schedule_delivery(delivery_time)
    update(status: :scheduled)
    SendNewsletterJob.set(wait_until: delivery_time).perform_later(self.id)
  end

  def send_now!
    update(status: :sending)
    SendNewsletterJob.perform_later(self.id)
  end
end
