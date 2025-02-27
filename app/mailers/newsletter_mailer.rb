class NewsletterMailer < ApplicationMailer
  # Send newsletter to subscriber
  def newsletter_email(newsletter, subscriber)
    @newsletter = newsletter
    @subscriber = subscriber
    @unsubscribe_url = unsubscribe_newsletter_subscriptions_url(token: subscriber.token)

    mail(
      to: subscriber.email,
      subject: newsletter.title,
    )
  end

  # Send subscription confirmation
  def subscription_confirmation(subscriber)
    @subscriber = subscriber
    @unsubscribe_url = unsubscribe_newsletter_subscriptions_url(token: subscriber.token)

    mail(
      to: subscriber.email,
      subject: "Newsletter Subscription Confirmation",
    )
  end

  # Send unsubscribe confirmation
  def unsubscribe_confirmation(subscriber)
    @subscriber = subscriber

    mail(
      to: subscriber.email,
      subject: "You've Been Unsubscribed from Our Newsletter",
    )
  end
end
