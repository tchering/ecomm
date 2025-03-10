import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "content"];

  connect() {
    // Close dropdown when clicking outside
    document.addEventListener("click", this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this));
  }

  toggle() {
    this.contentTarget.classList.toggle("hidden");
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.contentTarget.classList.add("hidden");
    }
  }
}
