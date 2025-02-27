require "rails_helper"

RSpec.describe ContactInquiriesController, type: :controller do
  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new contact inquiry" do
      get :new
      expect(assigns(:contact_inquiry)).to be_a_new(ContactInquiry)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          contact_inquiry: {
            name: "John Doe",
            email: "john@example.com",
            subject: "Product Question",
            message: "I have a question about your products.",
          },
        }
      end

      it "creates a new contact inquiry" do
        expect {
          post :create, params: valid_params
        }.to change(ContactInquiry, :count).by(1)
      end

      it "redirects to the root path with a success notice" do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to match(/successfully submitted/i)
      end

      it "enqueues a notification email job" do
        expect {
          post :create, params: valid_params
        }.to have_enqueued_job(ContactInquiryNotificationJob)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          contact_inquiry: {
            name: "",
            email: "invalid-email",
            subject: "",
            message: "",
          },
        }
      end

      it "does not create a new contact inquiry" do
        expect {
          post :create, params: invalid_params
        }.not_to change(ContactInquiry, :count)
      end

      it "renders the new template" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end

      it "assigns the contact inquiry with errors" do
        post :create, params: invalid_params
        expect(assigns(:contact_inquiry).errors).not_to be_empty
      end
    end
  end
end
