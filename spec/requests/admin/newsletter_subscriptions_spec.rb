require 'rails_helper'

RSpec.describe "Admin::NewsletterSubscriptions", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/newsletter_subscriptions/index"
      expect(response).to have_http_status(:success)
    end
  end

end
