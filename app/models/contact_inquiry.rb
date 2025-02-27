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
    pending: 0,
    in_progress: 1,
    resolved: 2,
    spam: 3,
  }

  # Callbacks
  before_create :set_default_status
  after_create_commit :notify_admin_of_new_inquiry

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

  def notify_admin_of_new_inquiry
    AdminUser.all.each do |admin|
      # Create in-app notification
      Notifications::NewInquiryNotification.create!(
        recipient: admin,
        data: {
          inquiry_id: id,
          customer_name: name,
          subject: subject,
        },
      )

      # Send email notification
      SendAdminInquiryNotificationJob.perform_later(admin.id, id)
    end
  end

  def set_default_status
    self.status ||= :pending
  end
end
