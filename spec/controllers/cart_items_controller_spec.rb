require "rails_helper"

RSpec.describe CartItemsController, type: :controller do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }

  before do
    session[:cart_id] = cart.id
  end

  describe "POST #create" do
    let(:valid_params) { { product_id: product.id, quantity: 1 } }

    context "with valid parameters" do
      it "creates a new cart item" do
        expect {
          post :create, params: valid_params, format: :turbo_stream
        }.to change(CartItem, :count).by(1)
      end

      it "assigns the correct product and quantity" do
        post :create, params: valid_params, format: :turbo_stream
        cart_item = CartItem.last
        expect(cart_item.product).to eq(product)
        expect(cart_item.quantity).to eq(1)
      end

      it "renders turbo stream response" do
        post :create, params: valid_params, format: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity for invalid product" do
        post :create, params: { product_id: "invalid" }, format: :turbo_stream
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product) }

    context "with valid parameters" do
      it "updates the cart item quantity" do
        patch :update, params: { id: cart_item.id, quantity: 2 }, format: :turbo_stream
        expect(cart_item.reload.quantity).to eq(2)
      end

      it "renders turbo stream response" do
        patch :update, params: { id: cart_item.id, quantity: 2 }, format: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity for invalid quantity" do
        patch :update, params: { id: cart_item.id, quantity: "invalid" }, format: :turbo_stream
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product) }

    it "destroys the cart item" do
      expect {
        delete :destroy, params: { id: cart_item.id }, format: :turbo_stream
      }.to change(CartItem, :count).by(-1)
    end

    it "renders turbo stream response" do
      delete :destroy, params: { id: cart_item.id }, format: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
    end
  end
end
