require "rails_helper"

RSpec.describe Admin::ContactInquiriesController, type: :controller do
  let(:admin) { create(:user, admin: true) }
  let(:inquiry) { create(:contact_inquiry) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    before do
      create_list(:contact_inquiry, 3)
    end

    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns all contact inquiries" do
      get :index
      expect(assigns(:contact_inquiries).count).to eq(4) # 3 created in before block + 1 from let
    end

    context "with status filter" do
      before do
        create(:contact_inquiry, status: :in_progress)
        create(:contact_inquiry, status: :resolved)
      end

      it "filters inquiries by status" do
        get :index, params: { status: "in_progress" }
        expect(assigns(:contact_inquiries).count).to eq(1)
        expect(assigns(:contact_inquiries).first.status).to eq("in_progress")
      end
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: inquiry.id }
      expect(response).to be_successful
    end

    it "assigns the requested contact inquiry" do
      get :show, params: { id: inquiry.id }
      expect(assigns(:contact_inquiry)).to eq(inquiry)
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      let(:valid_params) do
        { id: inquiry.id, contact_inquiry: { status: "in_progress" } }
      end

      it "updates the requested contact inquiry" do
        patch :update, params: valid_params
        inquiry.reload
        expect(inquiry.status).to eq("in_progress")
      end

      it "redirects to the contact inquiry with a success notice" do
        patch :update, params: valid_params
        expect(response).to redirect_to(admin_contact_inquiry_path(inquiry))
        expect(flash[:notice]).to match(/successfully updated/i)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { id: inquiry.id, contact_inquiry: { status: "invalid_status" } }
      end

      it "does not update the contact inquiry" do
        original_status = inquiry.status
        patch :update, params: invalid_params
        inquiry.reload
        expect(inquiry.status).to eq(original_status)
      end

      it "renders the show template" do
        patch :update, params: invalid_params
        expect(response).to render_template(:show)
      end
    end
  end

  describe "POST #respond" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          contact_inquiry_id: inquiry.id,
          contact_response: { message: "Thank you for your inquiry. We'll get back to you soon." },
        }
      end

      it "creates a new response" do
        expect {
          post :respond, params: valid_params
        }.to change(ContactResponse, :count).by(1)
      end

      it "updates the inquiry status to resolved" do
        post :respond, params: valid_params
        inquiry.reload
        expect(inquiry.status).to eq("resolved")
        expect(inquiry.resolved_at).not_to be_nil
      end

      it "redirects to the contact inquiry with a success notice" do
        post :respond, params: valid_params
        expect(response).to redirect_to(admin_contact_inquiry_path(inquiry))
        expect(flash[:notice]).to match(/response sent/i)
      end

      it "enqueues a response email job" do
        expect {
          post :respond, params: valid_params
        }.to have_enqueued_job(ContactResponseEmailJob)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          contact_inquiry_id: inquiry.id,
          contact_response: { message: "" },
        }
      end

      it "does not create a new response" do
        expect {
          post :respond, params: invalid_params
        }.not_to change(ContactResponse, :count)
      end

      it "does not update the inquiry status" do
        original_status = inquiry.status
        post :respond, params: invalid_params
        inquiry.reload
        expect(inquiry.status).to eq(original_status)
      end

      it "renders the show template" do
        post :respond, params: invalid_params
        expect(response).to render_template(:show)
      end
    end
  end
end
