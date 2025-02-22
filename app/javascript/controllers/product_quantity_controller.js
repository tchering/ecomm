import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "input"];

  connect() {
    this.submitForm = this.debounce(this.submitForm.bind(this), 300);
  }

  increment(event) {
    event.preventDefault();
    const currentValue = parseInt(this.inputTarget.value) || 1;
    const newValue = Math.min(currentValue + 1, 99);
    if (newValue !== currentValue) {
      this.inputTarget.value = newValue;
      this.submitForm();
    }
  }

  decrement(event) {
    event.preventDefault();
    const currentValue = parseInt(this.inputTarget.value) || 1;
    if (currentValue > 1) {
      this.inputTarget.value = currentValue - 1;
      this.submitForm();
    }
  }

  submitForm() {
    const originalValue = this.inputTarget.value;

    this.formTarget.requestSubmit().catch(() => {
      // Revert to original value on error
      this.inputTarget.value = originalValue;

      // Show error message
      const errorMessage = document.createElement("div");
      errorMessage.className = "text-red-500 text-sm mt-2";
      errorMessage.textContent = "Failed to update quantity. Please try again.";

      const existingError = this.formTarget.querySelector(".text-red-500");
      if (existingError) {
        existingError.remove();
      }

      this.formTarget.appendChild(errorMessage);

      // Remove error message after 3 seconds
      setTimeout(() => {
        errorMessage.remove();
      }, 3000);
    });
  }

  // Utility function to debounce form submissions
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
