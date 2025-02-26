import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];
  static values = {
    currentForm: String,
  };

  connect() {
    // Initialize animation classes for the container
    if (this.hasContainerTarget) {
      this.containerTarget.classList.add(
        "transition-all",
        "duration-500",
        "ease-in-out"
      );
    }
  }

  // Handle navigation to the login form
  navigateToLogin(event) {
    if (event) event.preventDefault();

    // Don't do anything if we're already on the login form
    if (this.currentFormValue === "login") return;

    // Set current form
    this.currentFormValue = "login";

    // Create a request to the login path but with Turbo disabled
    fetch(event.currentTarget.href, { headers: { Accept: "text/html" } })
      .then((response) => response.text())
      .then((html) => {
        // Start animation - fade out
        this.containerTarget.classList.add("opacity-0", "translate-y-4");

        // After animation completes, swap the content
        setTimeout(() => {
          // Extract form content from the response
          const tempDiv = document.createElement("div");
          tempDiv.innerHTML = html;
          const newContent = tempDiv.querySelector(".max-w-md");

          // Replace the content
          this.containerTarget.innerHTML = newContent.innerHTML;

          // Animate back in
          setTimeout(() => {
            this.containerTarget.classList.remove("opacity-0", "translate-y-4");
          }, 50);
        }, 300);
      });
  }

  // Handle navigation to the signup form
  navigateToSignup(event) {
    if (event) event.preventDefault();

    // Don't do anything if we're already on the signup form
    if (this.currentFormValue === "signup") return;

    // Set current form
    this.currentFormValue = "signup";

    // Create a request to the signup path but with Turbo disabled
    fetch(event.currentTarget.href, { headers: { Accept: "text/html" } })
      .then((response) => response.text())
      .then((html) => {
        // Start animation - fade out
        this.containerTarget.classList.add("opacity-0", "translate-y-4");

        // After animation completes, swap the content
        setTimeout(() => {
          // Extract form content from the response
          const tempDiv = document.createElement("div");
          tempDiv.innerHTML = html;
          const newContent = tempDiv.querySelector(".max-w-md");

          // Replace the content
          this.containerTarget.innerHTML = newContent.innerHTML;

          // Animate back in
          setTimeout(() => {
            this.containerTarget.classList.remove("opacity-0", "translate-y-4");
          }, 50);
        }, 300);
      });
  }
}
