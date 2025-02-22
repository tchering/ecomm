import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "content"];

  connect() {
    // Close dropdown when clicking outside
    this.clickHandler = this.handleClickOutside.bind(this);
    document.addEventListener("click", this.clickHandler);
  }

  disconnect() {
    document.removeEventListener("click", this.clickHandler);
  }

  toggle(event) {
    event.stopPropagation();
    this.contentTarget.classList.toggle("hidden");
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.contentTarget.classList.add("hidden");
    }
  }
}
