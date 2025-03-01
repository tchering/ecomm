module Admin
  module NewslettersHelper
    def newsletter_status_class(status)
      case status.to_s
      when "draft"
        "newsletter-status-draft"
      when "scheduled"
        "newsletter-status-scheduled"
      when "sending"
        "newsletter-status-sending"
      when "sent"
        "newsletter-status-sent"
      when "failed"
        "newsletter-status-failed"
      else
        "newsletter-status-draft"
      end
    end

    def recipient_status_class(status)
      case status.to_s
      when "queued"
        "bg-gray-100 text-gray-800"
      when "sent"
        "bg-green-100 text-green-800"
      when "failed"
        "bg-red-100 text-red-800"
      else
        "bg-gray-100 text-gray-800"
      end
    end
  end
end
