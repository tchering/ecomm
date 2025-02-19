import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "dropdown"]
  static values = {
    open: Boolean
  }

  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', (event) => {
      if (!this.element.contains(event.target)) {
        this.closeDropdown()
      }
    })
  }

  toggle() {
    this.openValue = !this.openValue
  }

  closeDropdown() {
    this.openValue = false
  }

  openValueChanged() {
    if (this.openValue) {
      this.dropdownTarget.classList.remove('hidden')
    } else {
      this.dropdownTarget.classList.add('hidden')
    }
  }

  select(event) {
    // Let the link handle the navigation
    this.closeDropdown()
  }
}
