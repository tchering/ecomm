require 'rails_helper'

RSpec.describe "Admin::ContactInquiries", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/contact_inquiries/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/contact_inquiries/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /respond" do
    it "returns http success" do
      get "/admin/contact_inquiries/respond"
      expect(response).to have_http_status(:success)
    end
  end

end
