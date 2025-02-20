import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["address", "latitude", "longitude", "results"];
  static values = {
    apiKey: String,
  };

  connect() {
    // Create results container
    this.resultsTarget.style.display = "none";
    console.log("Address autocomplete controller connected");
  }

  // Search as user types in address field
  async search() {
    const query = this.addressTarget.value;
    if (query.length < 3) {
      this.resultsTarget.style.display = "none";
      return;
    }

    const response = await fetch(
      `https://api.mapbox.com/geocoding/v5/mapbox.places/${query}.json?` +
        `access_token=${this.apiKeyValue}&` +
        `country=fra&` + // Restrict to Canada
        `types=address&` + // Return only addresses
        `language=en`
    );

    const data = await response.json();
    this.showResults(data.features);
  }

  showResults(features) {
    this.resultsTarget.innerHTML = "";
    this.resultsTarget.style.display = features.length ? "block" : "none";

    features.forEach((feature) => {
      const div = document.createElement("div");
      div.classList.add("p-2", "hover:bg-gray-100", "cursor-pointer");
      div.textContent = feature.place_name;
      div.addEventListener("click", () => this.selectAddress(feature));
      this.resultsTarget.appendChild(div);
    });
  }

  selectAddress(feature) {
    // Update form fields
    this.addressTarget.value = feature.place_name;
    this.latitudeTarget.value = feature.center[1];
    this.longitudeTarget.value = feature.center[0];

    // Hide results
    this.resultsTarget.style.display = "none";
  }
}
