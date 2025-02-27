class ContactResponse < ApplicationRecord
  belongs_to :contact_inquiry
  belongs_to :user

  validates :message, presence: true

  before_create :set_sent_at
  after_create :mark_inquiry_as_in_progress

  private

  def set_sent_at
    self.sent_at = Time.current
  end

  def mark_inquiry_as_in_progress
    contact_inquiry.mark_as_in_progress! if contact_inquiry.new?
  end
end
