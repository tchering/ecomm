# E-Commerce Application

This is a Ruby on Rails e-commerce application with advanced features including email notifications, newsletter management, and contact inquiry handling.

## Features

### Customer Features

- **Product Browsing**: Browse products by category, search for specific items
- **Shopping Cart**: Add products to cart, update quantities, remove items
- **Checkout Process**: Secure checkout with multiple payment options
- **User Accounts**: Register, login, view order history
- **Newsletter Subscription**: Subscribe to receive updates and promotions
- **Contact Form**: Submit inquiries and receive responses

### Admin Features

- **Product Management**: Add, edit, and remove products
- **Order Management**: View, process, and update order status
- **User Management**: Manage user accounts and permissions
- **Newsletter Management**: Send newsletters to subscribers, import/export subscriber lists
- **Contact Inquiry Management**: View and respond to customer inquiries
- **Background Job Monitoring**: Monitor email sending and other background tasks

## Technical Details

### Email Notifications

The application uses ActionMailer and Sidekiq for sending various types of emails:

- **Order Notifications**: Confirmation, status updates, shipping, delivery
- **Newsletter Emails**: Welcome emails, regular newsletters
- **Contact Responses**: Automated acknowledgments, admin responses

### Background Jobs

Background jobs are processed using Sidekiq:

- `OrderStatusUpdateJob`: Sends order status update emails
- `NewsletterWelcomeEmailJob`: Sends welcome emails to new subscribers
- `NewsletterDeliveryJob`: Sends newsletters to subscribers
- `ContactInquiryNotificationJob`: Notifies admins of new inquiries
- `ContactResponseEmailJob`: Sends responses to customer inquiries

### Models

- `Order`: Manages customer orders with various statuses
- `NewsletterSubscription`: Manages newsletter subscriptions
- `Newsletter`: Stores newsletter content for sending to subscribers
- `ContactInquiry`: Stores customer inquiries with status tracking
- `ContactResponse`: Stores admin responses to inquiries

## Setup and Installation

### Prerequisites

- Ruby 3.0.0 or higher
- Rails 7.0.0 or higher
- PostgreSQL
- Redis (for Sidekiq)

### Installation Steps

1. Clone the repository
   ```
   git clone https://github.com/yourusername/ecommerce.git
   cd ecommerce
   ```

2. Install dependencies
   ```
   bundle install
   ```

3. Setup the database
   ```
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. Start the Redis server
   ```
   redis-server
   ```

5. Start Sidekiq
   ```
   bundle exec sidekiq
   ```

6. Start the Rails server
   ```
   rails server
   ```

## Testing

The application includes comprehensive tests:

- Model tests for validations, associations, and methods
- Controller tests for actions and responses
- System tests for user flows
- Mailer tests for email content
- Job tests for background processing

Run the tests with:
```
bundle exec rspec
```

## Development

For development, the application uses Letter Opener for previewing emails without sending them.

## Deployment

The application is configured for easy deployment to Heroku or similar platforms.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
