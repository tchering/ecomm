import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // Remove any existing flash messages in the same container
    const container = this.element.parentElement;
    const existingFlashes = container.querySelectorAll(".flash");
    existingFlashes.forEach((flash) => flash.remove());

    // Add fade-out class after delay
    setTimeout(() => {
      if (this.element) {
        this.element.classList.add("fade-out");
        setTimeout(() => {
          if (this.element) {
            this.element.remove();
          }
        }, 500); // Remove after fade animation
      }
    }, 3000); // Start fade after 3 seconds
  }

  remove(event) {
    if (event.animationName === "fade-out") {
      this.element.remove();
    }
  }
}
