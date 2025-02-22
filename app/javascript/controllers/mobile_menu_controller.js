import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  connect() {
    // Initialize menu state
    this.isOpen = false;
  }

  toggle() {
    this.isOpen = !this.isOpen;

    if (this.isOpen) {
      // Show menu with transition
      this.menuTarget.classList.remove("hidden");
      // Use requestAnimationFrame to ensure the display change has taken effect
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          this.menuTarget.classList.add("opacity-100");
          this.menuTarget.classList.remove("opacity-0", "-translate-y-2");
        });
      });
    } else {
      // Hide menu with transition
      this.menuTarget.classList.add("opacity-0", "-translate-y-2");
      this.menuTarget.classList.remove("opacity-100");

      // Wait for transition to complete before hiding
      this.menuTarget.addEventListener(
        "transitionend",
        () => {
          if (!this.isOpen) {
            this.menuTarget.classList.add("hidden");
          }
        },
        { once: true }
      );
    }
  }

  // Cleanup when navigating away
  disconnect() {
    this.isOpen = false;
    this.menuTarget.classList.add("hidden");
    this.menuTarget.classList.remove("opacity-100");
    this.menuTarget.classList.add("opacity-0", "-translate-y-2");
  }
}
