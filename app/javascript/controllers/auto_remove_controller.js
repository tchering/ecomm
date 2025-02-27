import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    timeout: Number,
  };

  connect() {
    setTimeout(() => {
      this.element.classList.add("translate-y-full", "opacity-0");
      setTimeout(() => {
        this.element.remove();
      }, 500);
    }, this.timeoutValue);
  }
}
