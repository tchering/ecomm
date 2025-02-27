# Preview all emails at http://localhost:3000/rails/mailers/newsletter_mailer
class NewsletterMailerPreview < ActionMailer::Preview
  def newsletter_email
    newsletter = Newsletter.last || create_sample_newsletter
    subscriber = NewsletterSubscription.last || create_sample_subscription
    NewsletterMailer.newsletter_email(newsletter, subscriber)
  end

  def subscription_confirmation
    subscriber = NewsletterSubscription.last || create_sample_subscription
    NewsletterMailer.subscription_confirmation(subscriber)
  end

  def unsubscribe_confirmation
    subscriber = NewsletterSubscription.last || create_sample_subscription
    NewsletterMailer.unsubscribe_confirmation(subscriber)
  end

  private

  def create_sample_newsletter
    Newsletter.create!(
      title: "Sample Newsletter",
      content: "<h1>Welcome to our Newsletter!</h1><p>This is a sample newsletter for email previews.</p><p>Here are some of our latest products:</p><ul><li>Product 1</li><li>Product 2</li><li>Product 3</li></ul><p>Thank you for subscribing!</p>",
      status: "draft",
    )
  end

  def create_sample_subscription
    NewsletterSubscription.create!(
      email: "subscriber@example.com",
      name: "Sample Subscriber",
      active: true,
      subscribed_at: Time.current,
    )
  end
end
