require "rails_helper"

RSpec.describe Admin::NewsletterSubscriptionsController, type: :controller do
  let(:admin) { create(:user, admin: true) }
  let(:subscription) { create(:newsletter_subscription) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    before do
      create_list(:newsletter_subscription, 3)
    end

    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all newsletter subscriptions" do
      get :index
      expect(assigns(:newsletter_subscriptions).count).to eq(4) # 3 created in before block + 1 from let
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested subscription" do
      expect {
        delete :destroy, params: { id: subscription.id }
      }.to change(NewsletterSubscription, :count).by(-1)
    end

    it "redirects to the subscriptions list with a success notice" do
      delete :destroy, params: { id: subscription.id }
      expect(response).to redirect_to(admin_newsletter_subscriptions_path)
      expect(flash[:notice]).to match(/successfully removed/i)
    end
  end

  describe "POST #send_newsletter" do
    let(:valid_params) do
      {
        newsletter: {
          subject: "Monthly Newsletter",
          content: "Here are our latest updates and promotions.",
        },
      }
    end

    before do
      create_list(:newsletter_subscription, 5)
    end

    it "creates a new newsletter" do
      expect {
        post :send_newsletter, params: valid_params
      }.to change(Newsletter, :count).by(1)
    end

    it "enqueues newsletter delivery jobs for all subscribers" do
      expect {
        post :send_newsletter, params: valid_params
      }.to have_enqueued_job(NewsletterDeliveryJob).exactly(6) # 5 created in before block + 1 from let
    end

    it "redirects to the subscriptions list with a success notice" do
      post :send_newsletter, params: valid_params
      expect(response).to redirect_to(admin_newsletter_subscriptions_path)
      expect(flash[:notice]).to match(/newsletter is being sent/i)
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { newsletter: { subject: "", content: "" } }
      end

      it "does not create a new newsletter" do
        expect {
          post :send_newsletter, params: invalid_params
        }.not_to change(Newsletter, :count)
      end

      it "renders the index template" do
        post :send_newsletter, params: invalid_params
        expect(response).to render_template(:index)
      end

      it "assigns the newsletter with errors" do
        post :send_newsletter, params: invalid_params
        expect(assigns(:newsletter).errors).not_to be_empty
      end
    end
  end

  describe "POST #import" do
    let(:file) { fixture_file_upload("spec/fixtures/newsletter_subscriptions.csv", "text/csv") }

    it "imports subscriptions from the CSV file" do
      expect {
        post :import, params: { file: file }
      }.to change(NewsletterSubscription, :count)
    end

    it "redirects to the subscriptions list with a success notice" do
      post :import, params: { file: file }
      expect(response).to redirect_to(admin_newsletter_subscriptions_path)
      expect(flash[:notice]).to match(/successfully imported/i)
    end

    context "with invalid file" do
      it "redirects to the subscriptions list with an error notice" do
        post :import, params: { file: nil }
        expect(response).to redirect_to(admin_newsletter_subscriptions_path)
        expect(flash[:alert]).to match(/please upload a csv file/i)
      end
    end
  end

  describe "GET #export" do
    before do
      create_list(:newsletter_subscription, 3)
    end

    it "returns a CSV file" do
      get :export, format: :csv
      expect(response.content_type).to eq("text/csv")
      expect(response.headers["Content-Disposition"]).to include("attachment")
    end

    it "includes all subscriptions in the CSV" do
      get :export, format: :csv
      expect(response.body.split("\n").length).to eq(5) # header + 4 subscriptions
    end
  end
end
