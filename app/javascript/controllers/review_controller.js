import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "star",
    "ratingInput",
    "imagePreview",
    "modal",
    "modalImage",
  ];

  connect() {
    this.setupStarRating();
  }

  // Star rating functionality
  setupStarRating() {
    this.starTargets.forEach((star, index) => {
      star.addEventListener("mouseenter", () => this.highlightStars(index + 1));
      star.addEventListener("mouseleave", () => this.resetStars());
      star.addEventListener("click", () => this.setRating(index + 1));
    });
  }

  highlightStars(count) {
    this.starTargets.forEach((star, index) => {
      if (index < count) {
        star.classList.remove("far");
        star.classList.add("fas");
      } else {
        star.classList.remove("fas");
        star.classList.add("far");
      }
    });
  }

  resetStars() {
    const currentRating = parseInt(this.ratingInputTarget.value) || 0;
    this.highlightStars(currentRating);
  }

  setRating(rating) {
    this.ratingInputTarget.value = rating;
    this.highlightStars(rating);
  }

  // Image preview functionality
  handleImageUpload(event) {
    const files = event.target.files;
    this.imagePreviewTarget.innerHTML = "";

    Array.from(files).forEach((file) => {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader();
        reader.onload = (e) => this.addImagePreview(e.target.result);
        reader.readAsDataURL(file);
      }
    });
  }

  addImagePreview(imageUrl) {
    const preview = document.createElement("div");
    preview.className = "relative";
    preview.innerHTML = `
      <img src="${imageUrl}" class="w-full h-32 object-cover rounded-lg">
      <button type="button" class="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
              data-action="click->review#removeImage">
        <i class="fas fa-times"></i>
      </button>
    `;
    this.imagePreviewTarget.appendChild(preview);
  }

  removeImage(event) {
    event.preventDefault();
    event.target.closest(".relative").remove();
  }

  // Modal functionality
  openModal(event) {
    const imageUrl = event.currentTarget.dataset.imageUrl;
    this.modalImageTarget.src = imageUrl;
    this.modalTarget.classList.remove("hidden");
  }

  closeModal() {
    this.modalTarget.classList.add("hidden");
  }

  // Handle helpful/unhelpful votes
  async handleVote(event) {
    event.preventDefault();
    const button = event.currentTarget;
    const url = button.getAttribute("href");
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
        Accept: "application/json",
      },
    });

    if (response.ok) {
      const data = await response.json();
      this.updateVoteCount(button, data.helpful_score);
    }
  }

  updateVoteCount(button, score) {
    const countElement = button.querySelector(".vote-count");
    if (countElement) {
      countElement.textContent = score;
    }
  }
}
