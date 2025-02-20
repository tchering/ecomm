class Api::ChatbotController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:message]

  def message
    query = params[:message].to_s.strip
    order_number = extract_order_number(query)

    response = if order_number
        handle_order_query(order_number)
      else
        handle_general_query(query)
      end

    render json: { message: response }
  end

  def faqs
    faqs = Faq.all.group_by(&:category)
    render json: { faqs: faqs }
  end

  private

  def extract_order_number(query)
    # Match common order number patterns
    match = query.match(/order\s*#?\s*(\d+)/i) || query.match(/\b\d{5,}\b/)
    match[1] if match
  end

  def handle_order_query(order_number)
    order = Order.find_by(id: order_number)

    if order
      case order.status
      when "pending"
        "Order ##{order.id} is pending processing. We'll notify you once it's been processed. Expected processing time is 1-2 business days."
      when "processing"
        "Order ##{order.id} is currently being processed. It will be shipped soon! You'll receive a shipping confirmation email with tracking details."
      when "shipped"
        "Order ##{order.id} has been shipped! You should receive it within 3-5 business days. Check your email for tracking information."
      when "delivered"
        "Order ##{order.id} has been delivered. Thank you for shopping with us! If you have any issues with your order, please let us know."
      when "cancelled"
        "Order ##{order.id} was cancelled. If you didn't request this cancellation or have questions, please contact our support team."
      end
    else
      "I couldn't find an order with number ##{order_number}. Please check the number and try again, or provide your email address so I can look up your recent orders."
    end
  end

  def handle_general_query(query)
    # Try to find relevant FAQs
    faqs = Faq.find_relevant(query)

    if faqs.any?
      # If we have multiple matches, combine them
      if faqs.count > 1
        responses = faqs.map { |faq| faq.answer }
        "Here are a few answers that might help:\n\n" + responses.join("\n\n")
      else
        faqs.first.answer
      end
    else
      # Provide a more helpful default response based on the query context
      suggest_alternative_help(query)
    end
  end

  def suggest_alternative_help(query)
    # Common topics to suggest based on keywords
    suggestions = {
      /\b(ship|delivery|track)\w*\b/i => "For shipping related questions, please check our shipping policy or provide your order number for tracking information.",
      /\b(return|refund|exchange)\w*\b/i => "For returns and refunds, please visit our returns page or provide your order number for specific assistance.",
      /\b(pay|price|cost)\w*\b/i => "For payment related questions, you can check our payment methods page or ask about specific payment options.",
      /\b(product|item)\w*\b/i => "For product specific questions, please provide the product name or browse our catalog.",
      /\b(login|account|sign)\w*\b/i => "For account related help, you can visit our account management page or ask specific account questions.",
    }

    # Find matching suggestion or return default
    suggestions.each do |pattern, message|
      return message if query.match?(pattern)
    end

    "I'm not sure I understand your question. Could you please rephrase it or try one of these topics?\n" \
    "- Order status and tracking\n" \
    "- Shipping information\n" \
    "- Returns and refunds\n" \
    "- Payment methods\n" \
    "- Product information"
  end
end
