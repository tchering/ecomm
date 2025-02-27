class NewsletterSubscriptionsController < ApplicationController
  # Skip authentication for these actions
  skip_before_action :authenticate_user!, raise: false

  # Create a new subscription
  def create
    @subscription = NewsletterSubscription.new(subscription_params)

    respond_to do |format|
      if @subscription.save
        # Send confirmation email in background
        NewsletterMailer.subscription_confirmation(@subscription).deliver_later

        format.html { redirect_to root_path, notice: "Thank you for subscribing to our newsletter!" }
        format.json { render json: { success: true, message: "Subscription successful" }, status: :created }
        format.js
      else
        format.html { redirect_to root_path, alert: "Subscription failed: #{@subscription.errors.full_messages.join(", ")}" }
        format.json { render json: { success: false, errors: @subscription.errors.full_messages }, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # Unsubscribe from newsletter
  def unsubscribe
    @subscription = NewsletterSubscription.find_by_token(params[:token])

    if @subscription
      @subscription.unsubscribe!
      NewsletterMailer.unsubscribe_confirmation(@subscription).deliver_later
      redirect_to root_path, notice: "You have been successfully unsubscribed from our newsletter."
    else
      redirect_to root_path, alert: "Invalid unsubscribe link."
    end
  end

  private

  def subscription_params
    params.require(:newsletter_subscription).permit(:email, :name)
  end
end
