import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content"];
  static values = {
    open: Boolean,
  };

  connect() {
    this.closeAll();
  }

  toggle(event) {
    event.preventDefault();
    const clickedContent = event.currentTarget.nextElementSibling;

    if (clickedContent.classList.contains("hidden")) {
      this.closeAll();
      clickedContent.classList.remove("hidden");
      event.currentTarget.setAttribute("aria-expanded", "true");
      // Rotate the chevron icon
      event.currentTarget
        .querySelector(".fa-chevron-down")
        .classList.add("rotate-180");
    } else {
      clickedContent.classList.add("hidden");
      event.currentTarget.setAttribute("aria-expanded", "false");
      // Reset the chevron icon
      event.currentTarget
        .querySelector(".fa-chevron-down")
        .classList.remove("rotate-180");
    }
  }

  closeAll() {
    this.contentTargets.forEach((content) => {
      content.classList.add("hidden");
      content.previousElementSibling.setAttribute("aria-expanded", "false");
      content.previousElementSibling
        .querySelector(".fa-chevron-down")
        ?.classList.remove("rotate-180");
    });
  }
}
