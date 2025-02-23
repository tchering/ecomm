require 'rails_helper'

RSpec.describe "Wishlists", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/wishlists/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /toggle" do
    it "returns http success" do
      get "/wishlists/toggle"
      expect(response).to have_http_status(:success)
    end
  end

end
