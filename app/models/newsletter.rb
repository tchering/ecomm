class Newsletter < ApplicationRecord
  # Validations
  validates :subject, presence: true
  validates :content, presence: true
  validates :status, presence: true
  validates :scheduled_for, presence: true, if: :scheduled?

  # Enums
  enum status: {
    draft: "draft",
    scheduled: "scheduled",
    sending: "sending",
    sent: "sent",
    failed: "failed",
  }

  # Associations
  belongs_to :created_by, class_name: "AdminUser"
  has_many :newsletter_recipients
  has_many :newsletter_clicks
  has_many :newsletter_opens

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :drafts, -> { where(status: :draft) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :sent, -> { where(status: :sent) }

  # Callbacks
  before_save :set_preview_text, if: :content_changed?

  # Methods
  def schedule!(time)
    update!(status: :scheduled, scheduled_for: time)
    NewsletterSchedulerJob.set(wait_until: time).perform_later(id)
  end

  def send_now!
    update!(status: :sending)
    NewsletterSenderJob.perform_later(id)
  end

  def cancel!
    return unless scheduled?
    update!(status: :draft, scheduled_for: nil)
  end

  def duplicate
    new_newsletter = self.dup
    new_newsletter.subject = "Copy of #{subject}"
    new_newsletter.status = :draft
    new_newsletter.scheduled_for = nil
    new_newsletter.sent_at = nil
    new_newsletter.save!
    new_newsletter
  end

  def total_recipients
    newsletter_recipients.count
  end

  def open_rate
    return 0 if total_recipients.zero?
    (newsletter_opens.count.to_f / total_recipients * 100).round(2)
  end

  def click_rate
    return 0 if total_recipients.zero?
    (newsletter_clicks.count.to_f / total_recipients * 100).round(2)
  end

  private

  def set_preview_text
    return if preview_text.present?

    preview = ActionController::Base.helpers.strip_tags(content)
      .gsub(/\s+/, " ")
      .strip
      .truncate(150)
    self.preview_text = preview
  end
end
