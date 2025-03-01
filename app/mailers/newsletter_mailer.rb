class NewsletterMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

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

  def campaign(newsletter, subscription)
    @newsletter = newsletter
    @subscription = subscription
    @unsubscribe_url = unsubscribe_newsletter_subscriptions_url(token: subscription.token)
    @tracking_pixel = newsletter_tracking_url(token: subscription.token, newsletter_id: newsletter.id)

    # Process the content to add tracking
    @content = process_content(newsletter.content, subscription)

    mail(
      to: subscription.email,
      subject: newsletter.subject,
      template_path: "mailers/newsletter",
      template_name: "campaign",
    )
  end

  private

  def process_content(content, subscription)
    doc = Nokogiri::HTML(content)

    # Add tracking to all links
    doc.css("a").each do |link|
      original_url = link["href"]
      next unless original_url.present?

      tracking_url = newsletter_redirect_url(
        token: subscription.token,
        newsletter_id: @newsletter.id,
        url: original_url,
      )
      link["href"] = tracking_url
    end

    # Add tracking pixel
    tracking_img = doc.create_element(
      "img",
      src: @tracking_pixel,
      width: 1,
      height: 1,
      style: "display:none;",
    )
    doc.at_css("body").add_child(tracking_img)

    doc.to_html
  end
end
