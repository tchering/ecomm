module Notifications
  class NewOrderNotification < Notification
    def title
      "New Order Received"
    end

    def message
      "Order ##{data["order_id"]} has been placed by #{data["customer_name"]}"
    end

    def url
      Rails.application.routes.url_helpers.admin_order_path(data["order_id"])
    end
  end
end
