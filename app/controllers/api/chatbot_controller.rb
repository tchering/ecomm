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
        "Order ##{order.id} is pending processing. We'll notify you once it's been processed."
      when "processing"
        "Order ##{order.id} is currently being processed. It will be shipped soon!"
      when "shipped"
        "Order ##{order.id} has been shipped! You should receive it within 3-5 business days."
      when "delivered"
        "Order ##{order.id} has been delivered. Thank you for shopping with us!"
      when "cancelled"
        "Order ##{order.id} was cancelled. Please contact support if you have any questions."
      end
    else
      "I couldn't find an order with that number. Please check the number and try again."
    end
  end

  def handle_general_query(query)
    # Try to find a relevant FAQ
    faq = Faq.find_relevant(query)

    if faq
      faq.answer
    else
      # Default response if no relevant FAQ found
      "I'm sorry, I couldn't find a specific answer to your question. Please try rephrasing your question or contact our support team for assistance."
    end
  end
end
