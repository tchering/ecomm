import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  toggle(event) {
    // Prevent the default form submission
    event.preventDefault();

    // Get the form
    const form = event.target.closest("form");

    // Submit the form with the proper headers for turbo stream
    fetch(form.action, {
      method: "POST",
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: new FormData(form),
      credentials: "same-origin",
    })
      .then((response) => response.text())
      .then((html) => {
        Turbo.renderStreamMessage(html);
      });
  }
}
