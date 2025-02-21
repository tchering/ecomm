require "rails_helper"

RSpec.describe Cart, type: :model do
  describe "associations" do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe "#add_product" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }

    context "when product is not in cart" do
      it "creates a new cart item" do
        expect {
          cart.add_product(product)
        }.to change(cart.cart_items, :count).by(1)
      end

      it "sets the correct quantity" do
        cart_item = cart.add_product(product, 2)
        expect(cart_item.quantity).to eq(2)
      end

      it "sets the correct price" do
        cart_item = cart.add_product(product)
        expect(cart_item.price).to eq(product.price)
      end
    end

    context "when product is already in cart" do
      let!(:existing_cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it "does not create a new cart item" do
        expect {
          cart.add_product(product)
        }.not_to change(cart.cart_items, :count)
      end

      it "increases the quantity of existing item" do
        cart.add_product(product, 2)
        expect(existing_cart_item.reload.quantity).to eq(3)
      end
    end
  end

  describe "#subtotal" do
    let(:cart) { create(:cart) }
    let(:product1) { create(:product, price: 10.0) }
    let(:product2) { create(:product, price: 20.0) }

    before do
      create(:cart_item, cart: cart, product: product1, quantity: 2, price: product1.price)
      create(:cart_item, cart: cart, product: product2, quantity: 1, price: product2.price)
    end

    it "calculates the correct subtotal" do
      expect(cart.subtotal).to eq(40.0) # (10.0 * 2) + (20.0 * 1)
    end
  end

  describe "#tax" do
    let(:cart) { create(:cart) }
    let(:category) { create(:category, tax_rate: 10.0) }
    let(:product) { create(:product, category: category, price: 100.0) }

    before do
      create(:cart_item, cart: cart, product: product, quantity: 1, price: product.price)
    end

    it "calculates the correct tax amount" do
      expect(cart.tax).to eq(10.0) # 100.0 * 0.10
    end
  end

  describe "#total" do
    let(:cart) { create(:cart) }
    let(:category) { create(:category, tax_rate: 10.0) }
    let(:product) { create(:product, category: category, price: 100.0) }

    before do
      create(:cart_item, cart: cart, product: product, quantity: 1, price: product.price)
    end

    it "calculates the correct total with tax" do
      expect(cart.total).to eq(110.0) # 100.0 + (100.0 * 0.10)
    end
  end

  describe "#total_items" do
    let(:cart) { create(:cart) }

    before do
      create(:cart_item, cart: cart, quantity: 2)
      create(:cart_item, cart: cart, quantity: 3)
    end

    it "returns the total number of items in the cart" do
      expect(cart.total_items).to eq(5)
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:cart)).to be_valid
    end

    it "has a valid factory with items" do
      cart = create(:cart, :with_items)
      expect(cart.cart_items.count).to eq(3)
    end
  end
end
