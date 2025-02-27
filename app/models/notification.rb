class Notification < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :recipient, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  after_create_commit :broadcast_to_recipient
  after_update_commit :broadcast_update_if_read_changed

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def title
    self.class.name.demodulize.underscore.humanize
  end

  def message
    "You have a new notification"
  end

  def url
    "#"
  end

  private

  def broadcast_to_recipient
    broadcast_prepend_later_to(
      recipient,
      :notifications,
      target: "notifications-list",
      partial: "admin/notifications/#{self.class.name.demodulize.underscore}",
      locals: { notification: self },
      action: :prepend,
      title: title,
      message: message,
    )

    # Also update the unread count
    broadcast_update_later_to(
      recipient,
      :notifications,
      target: "unread-notifications-count",
      partial: "admin/notifications/unread_count",
      locals: { recipient: recipient },
      action: :update_count,
    )
  end

  def broadcast_update_if_read_changed
    if saved_change_to_read_at?
      # Update the notification in the list
      broadcast_replace_later_to(
        recipient,
        :notifications,
        target: dom_id(self),
        partial: "admin/notifications/#{self.class.name.demodulize.underscore}",
        locals: { notification: self },
        action: :replace,
      )

      # Update the unread count
      broadcast_update_later_to(
        recipient,
        :notifications,
        target: "unread-notifications-count",
        partial: "admin/notifications/unread_count",
        locals: { recipient: recipient },
        action: :update_count,
      )
    end
  end
end
