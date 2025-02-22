require "rails_helper"

RSpec.describe "Cart Items", type: :system do
  let!(:category) { create(:category) }
  let!(:product) { create(:product, :with_images, category: category) }
  let!(:cart) { create(:cart) }

  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "updating cart item quantity" do
    context "when product is already in cart" do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      before do
        # Set the cart_id in session
        page.driver.browser.execute_script("window.localStorage.setItem('cart_id', '#{cart.id}')")
        visit store_path(product)
      end

      it "allows incrementing quantity" do
        expect {
          find("[data-action='product-quantity#increment']").click
          sleep 0.5 # Wait for AJAX request
          cart_item.reload
        }.to change(cart_item, :quantity).by(1)
      end

      it "allows decrementing quantity" do
        cart_item.update(quantity: 2)
        visit store_path(product)

        expect {
          find("[data-action='product-quantity#decrement']").click
          sleep 0.5 # Wait for AJAX request
          cart_item.reload
        }.to change(cart_item, :quantity).by(-1)
      end

      it "prevents decrementing below 1" do
        expect {
          find("[data-action='product-quantity#decrement']").click
          sleep 0.5 # Wait for AJAX request
          cart_item.reload
        }.not_to change(cart_item, :quantity)
      end

      it "updates the cart notice when quantity changes" do
        find("[data-action='product-quantity#increment']").click
        sleep 0.5 # Wait for AJAX request

        within("#cart-notice-product-#{product.id}") do
          expect(page).to have_content("2 items in cart")
        end
      end
    end

    context "when adding a new product to cart" do
      before do
        visit store_path(product)
      end

      it "adds product with specified quantity" do
        fill_in "quantity", with: "3"
        click_button "ADD TO BAG"

        expect(page).to have_content("3 items in cart")
      end
    end
  end
end
