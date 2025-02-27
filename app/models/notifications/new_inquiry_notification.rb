module Notifications
  class NewInquiryNotification < Notification
    def title
      "New Contact Inquiry"
    end

    def message
      "#{data["customer_name"]} has sent an inquiry about: #{data["subject"]}"
    end

    def url
      Rails.application.routes.url_helpers.admin_contact_inquiry_path(data["inquiry_id"])
    end
  end
end
