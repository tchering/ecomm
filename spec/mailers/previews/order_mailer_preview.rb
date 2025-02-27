# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def order_confirmation
    order = Order.last || create_sample_order
    OrderMailer.order_confirmation(order)
  end

  def order_processing
    order = Order.last || create_sample_order
    OrderMailer.order_processing(order)
  end

  def order_shipped
    order = Order.last || create_sample_order
    OrderMailer.order_shipped(order)
  end

  def order_delivered
    order = Order.last || create_sample_order
    OrderMailer.order_delivered(order)
  end

  def order_cancelled
    order = Order.last || create_sample_order
    OrderMailer.order_cancelled(order)
  end

  private

  def create_sample_order
    # Create a sample order for preview purposes
    user = User.first || User.create!(
      email: "sample@example.com",
      password: "password",
      first_name: "Sample",
      last_name: "User",
    )

    product = Product.first || Product.create!(
      title: "Sample Product",
      description: "This is a sample product for email previews",
      price: 19.99,
    )

    order = Order.create!(
      user: user,
      name: "Sample User",
      email: "sample@example.com",
      phone: "123-456-7890",
      shipping_address: "123 Sample St",
      shipping_city: "Sample City",
      shipping_state: "Sample State",
      shipping_postal_code: "12345",
      shipping_country: "Sample Country",
      total: 19.99,
      status: "pending",
    )

    ProductOrder.create!(
      order: order,
      product: product,
      quantity: 1,
      price: 19.99,
    )

    order
  end
end
