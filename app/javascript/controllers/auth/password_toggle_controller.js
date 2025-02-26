import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "icon"];

  toggle() {
    // Toggle between password and text type
    const inputField = this.inputTarget;
    const currentType = inputField.type;

    // Toggle the input type
    inputField.type = currentType === "password" ? "text" : "password";

    // Toggle the icon (if icon target exists)
    if (this.hasIconTarget) {
      if (currentType === "password") {
        this.iconTarget.classList.remove("fa-eye");
        this.iconTarget.classList.add("fa-eye-slash");
      } else {
        this.iconTarget.classList.remove("fa-eye-slash");
        this.iconTarget.classList.add("fa-eye");
      }
    }
  }
}
