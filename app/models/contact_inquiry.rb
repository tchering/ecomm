class ContactInquiry < ApplicationRecord
  # Associations
  has_many :contact_responses, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true
  validates :message, presence: true

  # Enums
  enum status: {
    new: 0,
    in_progress: 1,
    resolved: 2,
    spam: 3,
  }

  # Callbacks
  before_create :set_default_status

  # Scopes
  scope :unresolved, -> { where.not(status: :resolved) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def mark_as_resolved!
    update(status: :resolved, resolved_at: Time.current)
  end

  def mark_as_in_progress!
    update(status: :in_progress)
  end

  def mark_as_spam!
    update(status: :spam)
  end

  private

  def set_default_status
    self.status ||= :new
  end
end
