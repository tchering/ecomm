class NewsletterClick < ApplicationRecord
  belongs_to :newsletter
  belongs_to :newsletter_subscription

  validates :url, presence: true
  validates :clicked_at, presence: true

  before_validation :set_clicked_at, on: :create

  private

  def set_clicked_at
    self.clicked_at ||= Time.current
  end
end
