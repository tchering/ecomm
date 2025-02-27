class NotificationChannel < ApplicationCable::Channel
  def subscribed
    if current_admin_user
      stream_for current_admin_user
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
