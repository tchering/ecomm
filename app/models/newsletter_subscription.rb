class NewsletterSubscription < ApplicationRecord
  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, uniqueness: true, allow_nil: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Callbacks
  before_create :generate_token
  before_create :set_defaults

  # Methods
  def subscribe!
    update(active: true, subscribed_at: Time.current, unsubscribed_at: nil)
  end

  def unsubscribe!
    update(active: false, unsubscribed_at: Time.current)
  end

  def self.find_by_token(token)
    where(token: token).first
  end

  private

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless self.class.exists?(token: random_token)
    end
  end

  def set_defaults
    self.active = true if self.active.nil?
    self.subscribed_at = Time.current
  end
end
