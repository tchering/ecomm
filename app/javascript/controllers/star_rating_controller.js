import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["star", "input"];
  static values = {
    rating: Number,
  };

  connect() {
    // Set initial rating if exists
    if (this.ratingValue) {
      this.highlightStars(this.ratingValue);
    }
  }

  // When mouse enters a star
  hover(event) {
    const star = event.currentTarget;
    const rating = parseInt(star.dataset.rating);
    this.highlightStars(rating);
  }

  // When mouse leaves the star container
  leave() {
    // Reset to current rating or clear if none
    this.highlightStars(this.ratingValue || 0);
  }

  // When a star is clicked
  select(event) {
    const star = event.currentTarget;
    const rating = parseInt(star.dataset.rating);
    this.ratingValue = rating;
    this.inputTarget.value = rating;

    // Trigger change event on input for form handling
    const changeEvent = new Event("change", { bubbles: true });
    this.inputTarget.dispatchEvent(changeEvent);
  }

  // Helper method to highlight stars
  highlightStars(rating) {
    this.starTargets.forEach((star, index) => {
      const starRating = index + 1;
      if (starRating <= rating) {
        star.classList.remove("text-gray-300");
        star.classList.add("text-yellow-400");
      } else {
        star.classList.remove("text-yellow-400");
        star.classList.add("text-gray-300");
      }
    });
  }
}
