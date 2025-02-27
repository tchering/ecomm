require "rails_helper"

RSpec.describe NewsletterSubscriptionsController, type: :controller do
  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) { { newsletter_subscription: { email: "test@example.com" } } }

      it "creates a new subscription" do
        expect {
          post :create, params: valid_params
        }.to change(NewsletterSubscription, :count).by(1)
      end

      it "redirects to the root path with a success notice" do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to match(/successfully subscribed/i)
      end

      it "enqueues a welcome email job" do
        expect {
          post :create, params: valid_params
        }.to have_enqueued_job(NewsletterWelcomeEmailJob)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { newsletter_subscription: { email: "" } } }

      it "does not create a new subscription" do
        expect {
          post :create, params: invalid_params
        }.not_to change(NewsletterSubscription, :count)
      end

      it "redirects to the root path with an error notice" do
        post :create, params: invalid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/could not subscribe/i)
      end
    end

    context "with duplicate email" do
      before do
        create(:newsletter_subscription, email: "existing@example.com")
      end

      let(:duplicate_params) { { newsletter_subscription: { email: "existing@example.com" } } }

      it "does not create a new subscription" do
        expect {
          post :create, params: duplicate_params
        }.not_to change(NewsletterSubscription, :count)
      end

      it "redirects to the root path with an error notice" do
        post :create, params: duplicate_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/already subscribed/i)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:subscription) { create(:newsletter_subscription) }

    context "with valid token" do
      it "destroys the subscription" do
        expect {
          delete :destroy, params: { token: subscription.unsubscribe_token }
        }.to change(NewsletterSubscription, :count).by(-1)
      end

      it "redirects to the root path with a success notice" do
        delete :destroy, params: { token: subscription.unsubscribe_token }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to match(/successfully unsubscribed/i)
      end
    end

    context "with invalid token" do
      it "does not destroy any subscription" do
        expect {
          delete :destroy, params: { token: "invalid-token" }
        }.not_to change(NewsletterSubscription, :count)
      end

      it "redirects to the root path with an error notice" do
        delete :destroy, params: { token: "invalid-token" }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/could not unsubscribe/i)
      end
    end
  end
end
