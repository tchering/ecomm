require 'rails_helper'

RSpec.describe "NewsletterSubscriptions", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/newsletter_subscriptions/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /unsubscribe" do
    it "returns http success" do
      get "/newsletter_subscriptions/unsubscribe"
      expect(response).to have_http_status(:success)
    end
  end

end
