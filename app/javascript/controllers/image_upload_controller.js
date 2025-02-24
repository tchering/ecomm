import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "preview"];

  preview(event) {
    this.clearPreviews();

    Array.from(event.target.files).forEach((file) => {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader();
        reader.onload = (e) => this.addPreview(e.target.result);
        reader.readAsDataURL(file);
      }
    });
  }

  addPreview(imageUrl) {
    const previewContainer = document.createElement("div");
    previewContainer.className = "relative";
    previewContainer.innerHTML = `
      <img src="${imageUrl}" class="w-full h-32 object-cover rounded-lg">
      <button type="button"
              class="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600 focus:outline-none"
              data-action="click->image-upload#removePreview">
        <i class="fas fa-times"></i>
      </button>
    `;
    this.previewTarget.appendChild(previewContainer);
  }

  removePreview(event) {
    event.preventDefault();
    const previewElement = event.target.closest(".relative");
    previewElement.remove();
  }

  clearPreviews() {
    this.previewTarget.innerHTML = "";
  }
}
