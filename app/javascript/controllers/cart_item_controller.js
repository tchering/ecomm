import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity"]

  connect() {
    this.debouncedUpdate = this.debounce(this.updateQuantity.bind(this), 300)
  }

  increment(event) {
    event.preventDefault()
    const input = this.quantityTarget
    const currentValue = parseInt(input.value) || 1
    const newValue = Math.min(currentValue + 1, 99)
    
    if (newValue !== currentValue) {
      input.value = newValue
      this.updateQuantity()
    }
  }

  decrement(event) {
    event.preventDefault()
    const input = this.quantityTarget
    const currentValue = parseInt(input.value) || 1
    
    if (currentValue > 1) {
      input.value = currentValue - 1
      this.updateQuantity()
    }
  }

  updateQuantity() {
    const form = this.element.querySelector('form')
    if (form) {
      const formData = new FormData(form)
      
      // Submit the form using fetch to handle the response
      fetch(form.action, {
        method: 'PATCH',
        body: formData,
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        credentials: 'same-origin'
      })
      .then(response => response.text())
      .then(html => {
        const parser = new DOMParser()
        const doc = parser.parseFromString(html, 'text/html')
        const streams = doc.querySelectorAll('turbo-stream')
        streams.forEach(stream => {
          const template = stream.querySelector('template')
          if (template) {
            const target = document.getElementById(stream.getAttribute('target'))
            if (target) {
              if (stream.getAttribute('action') === 'replace') {
                target.innerHTML = template.innerHTML
              } else if (stream.getAttribute('action') === 'remove') {
                target.remove()
              }
            }
          }
        })
      })
    }
  }

  // Utility function to debounce updates
  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
}
