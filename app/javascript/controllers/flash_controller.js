import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["message"];

  connect() {
    // Automatically dismiss flash messages after 5 seconds
    setTimeout(() => {
      this.dismiss();
    }, 5000);
  }

  dismiss() {
    this.messageTarget.classList.add("opacity-0");
        setTimeout(() => {
      this.element.remove();
    }, 300);
  }
}
