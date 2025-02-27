require 'rails_helper'

RSpec.describe "Admin::Newsletters", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/newsletters/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/newsletters/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/admin/newsletters/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/newsletters/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/admin/newsletters/update"
      expect(response).to have_http_status(:success)
    end
  end

end
