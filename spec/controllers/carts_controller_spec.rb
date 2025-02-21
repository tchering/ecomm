require "rails_helper"

RSpec.describe CartsController, type: :controller do
  let(:cart) { create(:cart) }

  before do
    session[:cart_id] = cart.id
  end

  describe "GET #show" do
    let!(:cart_items) { create_list(:cart_item, 3, cart: cart) }

    it "assigns @cart_items" do
      get :show
      expect(assigns(:cart_items)).to match_array(cart_items)
    end

    it "includes product images in cart items" do
      get :show
      expect(assigns(:cart_items).first.product.images_attachments).to be_loaded
    end
  end

  describe "DELETE #destroy" do
    it "destroys the cart" do
      expect {
        delete :destroy
      }.to change(Cart, :count).by(-1)
    end

    it "removes cart_id from session" do
      delete :destroy
      expect(session[:cart_id]).to be_nil
    end

    it "redirects to root path" do
      delete :destroy
      expect(response).to redirect_to(root_path)
    end

    it "sets a notice message" do
      delete :destroy
      expect(flash[:notice]).to eq("Your cart has been cleared.")
    end
  end
end
