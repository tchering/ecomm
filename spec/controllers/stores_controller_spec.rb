require "rails_helper"

RSpec.describe StoresController, type: :controller do
  describe "GET #index" do
    let!(:category) { create(:category) }
    let!(:products) { create_list(:product, 3, category: category) }

    it "assigns @categories" do
      get :index
      expect(assigns(:categories)).to eq([category])
    end

    it "assigns @products" do
      get :index
      expect(assigns(:products)).to match_array(products)
    end

    it "assigns filtered @products when category param is present" do
      other_category = create(:category)
      other_product = create(:product, category: other_category)

      get :index, params: { category: category.id }
      expect(assigns(:products)).to match_array(products)
      expect(assigns(:products)).not_to include(other_product)
    end

    it "assigns @trending_products" do
      get :index
      expect(assigns(:trending_products)).to be_present
    end

    context "with turbo_stream request" do
      it "renders products_grid partial" do
        get :index, params: { category: category.id }, as: :turbo_stream
        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end
  end

  describe "GET #show" do
    let(:product) { create(:product) }

    it "assigns @product" do
      get :show, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
    end

    it "assigns @cart_item when product is in cart" do
      cart = create(:cart)
      cart_item = create(:cart_item, cart: cart, product: product)
      session[:cart_id] = cart.id

      get :show, params: { id: product.id }
      expect(assigns(:cart_item)).to eq(cart_item)
    end
  end
end
