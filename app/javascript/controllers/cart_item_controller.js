import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["quantity"];

  connect() {
    this.debouncedUpdate = this.debounce(this.updateQuantity.bind(this), 300);
  }

  increment(event) {
    event.preventDefault();
    const input = this.quantityTarget;
    const currentValue = parseInt(input.value) || 1;
    const newValue = Math.min(currentValue + 1, 99);

    if (newValue !== currentValue) {
      input.value = newValue;
      this.updateQuantity();
    }
  }

  decrement(event) {
    event.preventDefault();
    const input = this.quantityTarget;
    const currentValue = parseInt(input.value) || 1;

    if (currentValue > 1) {
      input.value = currentValue - 1;
      this.updateQuantity();
    }
  }

  updateQuantity() {
    const form = this.element.querySelector("form");
    if (form) {
      const formData = new FormData(form);

      // Submit the form using fetch and let Turbo handle the response
      fetch(form.action, {
        method: "PATCH",
        body: formData,
        headers: {
          Accept: "text/vnd.turbo-stream.html",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        credentials: "same-origin",
      })
        .then((response) => {
          if (response.ok) {
            // Let Turbo handle the response
            return response.text().then((html) => {
              Turbo.renderStreamMessage(html);
            });
          }
        })
        .catch((error) => {
          console.error("Error updating quantity:", error);
        });
    }
  }

  // Utility function to debounce updates
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
}
