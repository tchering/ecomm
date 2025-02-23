class OrderInvoicePdf < Prawn::Document
  def initialize(order)
    super(page_size: "A4")
    @order = order
    generate_invoice
  end

  private

  def generate_invoice
    # Header
    header
    move_down 20

    # Billing Information
    billing_info
    move_down 20

    # Items
    items_table
    move_down 20

    # Summary
    summary
    move_down 20

    # Footer
    footer
  end

  def header
    text "INVOICE", size: 24, style: :bold, align: :center
    move_down 10
    text "Order ##{@order.id}", size: 14, align: :center
    text "Date: #{@order.created_at.strftime("%B %d, %Y")}", size: 12, align: :center
  end

  def billing_info
    # Store Information
    text "From:", size: 12, style: :bold
    text "Ecommerce Store "
    text "123 Store Street"
    text "Store City, ST 12345"
    text "store@example.com"
    move_down 20

    # Customer Information
    text "Bill To:", size: 12, style: :bold
    text @order.name
    text @order.email
    text @order.shipping_full_address
  end

  def items_table
    table_data = [["#", "Item", "Quantity", "Unit Price", "Total"]]

    @order.product_orders.each_with_index do |item, index|
      table_data << [
        index + 1,
        item.product.title,
        item.quantity,
        number_to_currency(item.price),
        number_to_currency(item.price * item.quantity),
      ]
    end

    table(table_data, header: true, width: bounds.width) do
      row(0).style(background_color: "CCCCCC", font_style: :bold)
      columns([3, 4]).style(align: :right)
    end
  end

  def summary
    move_down 10
    subtotal = @order.subtotal
    tax = @order.tax_amount
    total = @order.total

    summary_data = [
      ["Subtotal:", number_to_currency(subtotal)],
      ["Tax:", number_to_currency(tax)],
      ["Total:", number_to_currency(total)],
    ]

    table(summary_data, position: :right, width: 200) do
      columns(1).style(align: :right)
      rows(2).style(font_style: :bold)
    end
  end

  def footer
    move_down 50
    text "Thank you for your business!", align: :center, size: 14, style: :bold
    move_down 10
    text "For any questions, please contact support@example.com", align: :center, size: 10
  end

  def number_to_currency(amount)
    sprintf("$%.2f", amount)
  end
end
