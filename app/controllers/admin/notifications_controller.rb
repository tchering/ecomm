module Admin
  class NotificationsController < AdminController
    before_action :set_notification, only: [:mark_as_read]

    def index
      @filter = params[:filter] || "unread"

      @notifications = current_admin_user.notifications

      # Filter notifications based on read status
      @notifications = case @filter
        when "all"
          @notifications
        when "read"
          @notifications.read
        else # 'unread' is default
          @notifications.unread
        end

      @notifications = @notifications.order(created_at: :desc)
        .page(params[:page])
        .per(10)
    end

    def mark_as_read
      @notification.mark_as_read!

      respond_to do |format|
        format.html { redirect_to admin_notifications_path, notice: "Notification marked as read" }
        format.turbo_stream
      end
    end

    def mark_all_as_read
      current_admin_user.notifications.unread.update_all(read_at: Time.current)

      # Broadcast the updated count to all clients
      broadcast_update_to(
        current_admin_user,
        :notifications,
        target: "unread-notifications-count",
        partial: "admin/notifications/unread_count",
        locals: { recipient: current_admin_user },
        action: :update_count,
      )

      redirect_to admin_notifications_path, notice: "All notifications marked as read"
    end

    private

    def set_notification
      @notification = current_admin_user.notifications.find(params[:id])
    end
  end
end
