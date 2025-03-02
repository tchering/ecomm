import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notification"];
  static values = {
    autoDismiss: { type: Boolean, default: true },
    dismissAfter: { type: Number, default: 5000 },
  };

  connect() {
    // Initialize any necessary state
    this.dismissTimeout = null;

    // Listen for cart:itemAdded events
    this.boundShowHandler = this.show.bind(this);
    document.addEventListener("cart:itemAdded", this.boundShowHandler);
  }

  disconnect() {
    // Clean up event listener
    document.removeEventListener("cart:itemAdded", this.boundShowHandler);

    // Clear any existing timeout
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout);
      this.dismissTimeout = null;
    }
  }

  show(event) {
    const { product, image, quantity, price } = event.detail;

    // Update notification content
    this.notificationTarget.innerHTML = this.buildNotificationHTML(
      product,
      image,
      quantity,
      price
    );

    // Show the notification with animation
    this.notificationTarget.classList.remove("translate-x-full", "opacity-0");
    this.notificationTarget.classList.add("translate-x-0", "opacity-100");

    // Set up auto-dismiss
    this.setupAutoDismiss();
  }

  dismiss() {
    // Hide the notification with animation
    this.notificationTarget.classList.remove("translate-x-0", "opacity-100");
    this.notificationTarget.classList.add("translate-x-full", "opacity-0");

    // Clear any existing timeout
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout);
      this.dismissTimeout = null;
    }
  }

  // Reset the auto-dismiss timer when user interacts with the notification
  resetTimer() {
    if (this.autoDismissValue) {
      if (this.dismissTimeout) {
        clearTimeout(this.dismissTimeout);
      }
      this.setupAutoDismiss();
    }
  }

  setupAutoDismiss() {
    if (this.autoDismissValue) {
      if (this.dismissTimeout) {
        clearTimeout(this.dismissTimeout);
      }
      this.dismissTimeout = setTimeout(() => {
        this.dismiss();
      }, this.dismissAfterValue);
    }
  }

  // Helper to build the notification HTML
  buildNotificationHTML(product, image, quantity, price) {
    return `
      <div class="flex items-start space-x-4 p-4">
        <div class="flex-shrink-0 w-16 h-16">
          <img src="${image}" alt="${product.title}" class="w-full h-full object-cover rounded-md">
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900">
            Added to Cart
          </p>
          <p class="mt-1 text-sm text-gray-500">
            ${quantity}x ${product.title}
          </p>
          <p class="mt-1 text-sm font-medium text-gray-900">
            ${price}
          </p>
        </div>
        <div class="flex-shrink-0 self-center">
          <a href="/cart" class="text-sm font-medium text-indigo-600 hover:text-indigo-500">
            View Cart
            <span aria-hidden="true"> →</span>
          </a>
        </div>
      </div>
    `;
  }
}
