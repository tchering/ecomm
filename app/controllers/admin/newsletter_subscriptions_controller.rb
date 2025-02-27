module Admin
  class NewsletterSubscriptionsController < AdminController
    before_action :set_subscription, only: [:show, :edit, :update, :destroy]

    # List all subscriptions
    def index
      @subscriptions = NewsletterSubscription.all.order(created_at: :desc).page(params[:page]).per(20)

      # Filter by status if provided
      if params[:status].present?
        @subscriptions = @subscriptions.where(active: params[:status] == "active")
      end
    end

    # Show subscription details
    def show
    end

    # Edit subscription
    def edit
    end

    # Update subscription
    def update
      if @subscription.update(subscription_params)
        redirect_to admin_newsletter_subscriptions_path, notice: "Subscription was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Delete subscription
    def destroy
      @subscription.destroy
      redirect_to admin_newsletter_subscriptions_path, notice: "Subscription was successfully deleted."
    end

    private

    def set_subscription
      @subscription = NewsletterSubscription.find(params[:id])
    end

    def subscription_params
      params.require(:newsletter_subscription).permit(:email, :name, :active)
    end
  end
end
