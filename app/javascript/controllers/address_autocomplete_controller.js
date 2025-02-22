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
    // Parse the address components from the Mapbox response
    const context = feature.context || [];
    const addressComponents = {
      streetAddress: feature.place_name.split(",")[0],
      city: context.find((c) => c.id.startsWith("place"))?.text,
      state: context.find((c) => c.id.startsWith("region"))?.text,
      postalCode: context.find((c) => c.id.startsWith("postcode"))?.text,
      country: context.find((c) => c.id.startsWith("country"))?.text,
    };

    // Find the form fields - handle both checkout and profile forms
    const formPrefix = this.addressTarget.id.includes("shipping")
      ? "order_shipping_"
      : "";

    // Update the street address field
    this.addressTarget.value = addressComponents.streetAddress;

    // Update other address fields if they exist
    const cityField = document.getElementById(`${formPrefix}city`);
    const stateField = document.getElementById(`${formPrefix}state`);
    const postalCodeField = document.getElementById(`${formPrefix}postal_code`);
    const countryField = document.getElementById(`${formPrefix}country`);

    if (cityField) cityField.value = addressComponents.city || "";
    if (stateField) stateField.value = addressComponents.state || "";
    if (postalCodeField)
      postalCodeField.value = addressComponents.postalCode || "";
    if (countryField) countryField.value = addressComponents.country || "";

    // Update coordinates
    if (this.hasLatitudeTarget) this.latitudeTarget.value = feature.center[1];
    if (this.hasLongitudeTarget) this.longitudeTarget.value = feature.center[0];

    // Hide results
    this.resultsTarget.style.display = "none";
  }
}
