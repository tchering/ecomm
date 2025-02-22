import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "addressForm",
    "defaultAddressSection",
    "saveAddressCheckbox",
    "defaultAddressCheckbox",
  ];

  connect() {
    // Initialize the form state based on the selected address
    const savedAddressRadio = document.querySelector(
      'input[name="address_choice"][value="saved"]'
    );
    if (savedAddressRadio && savedAddressRadio.checked) {
      const defaultAddress = document.querySelector(
        'input[name="saved_address_id"][checked]'
      );
      if (defaultAddress) {
        this.fillAddressForm({ target: defaultAddress });
      }
    }

    // Initialize checkbox states
    this.toggleDefaultAddressOption({ target: this.saveAddressCheckboxTarget });
  }

  toggleDefaultAddressOption(event) {
    if (this.hasDefaultAddressCheckboxTarget) {
      const isChecked = event.target.checked;
      this.defaultAddressCheckboxTarget.disabled = !isChecked;

      if (!isChecked) {
        this.defaultAddressCheckboxTarget.checked = false;
      }
    }
  }

  useSavedAddress(event) {
    if (event.target.checked) {
      document.getElementById("new-address-form").classList.add("hidden");
      // Disable and uncheck the save address options when using saved address
      if (this.hasSaveAddressCheckboxTarget) {
        this.saveAddressCheckboxTarget.checked = false;
        this.saveAddressCheckboxTarget.disabled = true;
      }
      if (this.hasDefaultAddressCheckboxTarget) {
        this.defaultAddressCheckboxTarget.checked = false;
        this.defaultAddressCheckboxTarget.disabled = true;
      }

      const defaultAddress = document.querySelector(
        'input[name="saved_address_id"][checked]'
      );
      if (defaultAddress) {
        defaultAddress.checked = true;
        this.fillAddressForm({ target: defaultAddress });
      }
    }
  }

  useNewAddress(event) {
    if (event.target.checked) {
      document.getElementById("new-address-form").classList.remove("hidden");
      // Enable the save address checkbox when using new address
      if (this.hasSaveAddressCheckboxTarget) {
        this.saveAddressCheckboxTarget.disabled = false;
      }
      this.clearAddressForm();
    }
  }

  showNewAddressForm() {
    const form = document.getElementById("new-address-form");
    if (form) {
      form.classList.remove("hidden");
    }
  }

  hideNewAddressForm() {
    const form = document.getElementById("new-address-form");
    if (form) {
      form.classList.add("hidden");
    }
  }

  fillAddressForm(event) {
    const radio = event.target;
    if (!radio.checked) return;

    const addressData = JSON.parse(radio.dataset.address);

    document.getElementById("order_shipping_address").value =
      addressData.street_address || "";
    document.getElementById("order_shipping_apartment").value =
      addressData.apartment || "";
    document.getElementById("order_shipping_city").value =
      addressData.city || "";
    document.getElementById("order_shipping_state").value =
      addressData.state || "";
    document.getElementById("order_shipping_postal_code").value =
      addressData.postal_code || "";
    document.getElementById("order_shipping_country").value =
      addressData.country || "";
  }

  clearAddressForm() {
    document.getElementById("order_shipping_address").value = "";
    document.getElementById("order_shipping_apartment").value = "";
    document.getElementById("order_shipping_city").value = "";
    document.getElementById("order_shipping_state").value = "";
    document.getElementById("order_shipping_postal_code").value = "";
    document.getElementById("order_shipping_country").value = "";
  }
}
