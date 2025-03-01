class NewsletterOpen < ApplicationRecord
  belongs_to :newsletter
  belongs_to :newsletter_subscription

  validates :opened_at, presence: true

  before_validation :set_opened_at, on: :create

  private

  def set_opened_at
    self.opened_at ||= Time.current
  end
end
