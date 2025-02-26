class OrderInvoicePdf < Prawn::Document
  def initialize(order)
    super(page_size: "A4", margin: 50)
    @order = order
    font "Helvetica" # Use built-in Helvetica font
    generate_invoice
  end

  private

  def generate_invoice
    # Branding and Header
    branding
    move_down 20

    # Order Details
    order_details
    move_down 20

    # Billing Information
    billing_info
    move_down 30

    # Items Table
    items_table
    move_down 30

    # Summary
    summary
    move_down 30

    # Footer
    footer
  end

  def branding
    image Rails.root.join("app/assets/images/logo.png"), width: 100, position: :center if File.exist?(Rails.root.join("app/assets/images/logo.png"))
    move_down 10
    text "INVOICE", size: 28, style: :bold, align: :center, color: "333333"
    move_down 5
    text "Order #INV-#{@order.id.to_s.rjust(6, '0')}", size: 16, align: :center, color: "666666"
    text "Date: #{@order.created_at.strftime("%B %d, %Y")}", size: 12, align: :center, color: "666666"
    stroke_horizontal_rule
    move_down 10
  end

  def order_details
    text "Order Details", size: 14, style: :bold
    move_down 5
    data = [
      ["Order Status:", @order.status.humanize],
      # ["Payment Status:", @order.payment_status.humanize],
      ["Order Date:", @order.created_at.strftime("%B %d, %Y %I:%M %p")]
    ]
    table(data, cell_style: { size: 10, padding: [2, 5], borders: [] }, width: bounds.width) do
      column(0).style(align: :right, text_color: "666666")
      column(1).style(align: :left, text_color: "333333")
    end
    move_down 10
  end

  def billing_info
    bounding_box([0, cursor], width: bounds.width / 2) do
      text "From:", size: 12, style: :bold, color: "333333"
      text "Ecommerce Store", color: "333333"
      text "123 Store Street", color: "333333"
      text "Store City, ST 12345", color: "333333"
      text "store@example.com", color: "333333"
    end

    bounding_box([bounds.width / 2, cursor], width: bounds.width / 2) do
      text "Bill To:", size: 12, style: :bold, color: "333333"
      text @order.name, color: "333333"
      text @order.email, color: "333333"
      text @order.shipping_full_address, color: "333333"
    end
  end

  def items_table
    table_data = [["#", "Item Description", "Qty", "Unit Price", "Total"]]
    @order.product_orders.each_with_index do |item, index|
      table_data << [
        index + 1,
        item.product.title,
        item.quantity,
        { content: number_to_currency(item.price), align: :right },
        { content: number_to_currency(item.price * item.quantity), align: :right }
      ]
    end

    table(table_data, header: true, width: bounds.width, cell_style: { size: 10, padding: 5 }) do
      row(0).style(background_color: "E6E6FA", text_color: "333333", font_style: :bold, borders: [:top, :bottom])
      row(0).columns(0..4).borders = [:top, :bottom]
      columns(3..4).style(align: :right)
      self.row_colors = ["FFFFFF", "F5F5F5"]
      self.header = true
    end
  end

  def summary
    subtotal = @order.subtotal
    tax = @order.tax_amount
    total = @order.total

    summary_data = [
      ["Subtotal:", { content: number_to_currency(subtotal), align: :right }],
      ["Tax (VAT):", { content: number_to_currency(tax), align: :right }],
      ["Total Amount:", { content: number_to_currency(total), align: :right, font_style: :bold }]
    ]

    table(summary_data, position: :right, width: 200, cell_style: { size: 10, padding: [2, 5], borders: [] }) do
      column(0).style(align: :left, text_color: "666666")
      column(1).style(align: :right, text_color: "333333")
      row(2).style(text_color: "333333", font_style: :bold)
    end
  end

  def footer
    move_down 50
    stroke_horizontal_rule
    move_down 10
    text "Thank you for your purchase!", align: :center, size: 14, style: :bold, color: "333333"
    move_down 5
    text "For inquiries, contact us at support@example.com or call +1-800-555-1234", align: :center, size: 10, color: "666666"
    number_pages "Page <page> of <total>", at: [bounds.right - 50, 0], size: 8, color: "666666"
  end

  def number_to_currency(amount)
    sprintf("$%.2f", amount)
  end
end
